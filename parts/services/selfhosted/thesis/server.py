#!/usr/bin/env python3
"""
Self-hosted server for the "Synthesis of Medical Data" textbook.

* Serves site.html
* Stores ALL state server-side in a single JSON file (task progress + notes)
* Proxies / caches Hacker News + Reddit lookups so the browser never talks to
  third parties directly

Pure standard library, no pip dependencies.

Environment variables:
  THESIS_HOST      bind address            (default 127.0.0.1)
  THESIS_PORT      bind port               (default 9999)
  THESIS_DATA_DIR  where state is stored   (default ./data)
  THESIS_SITE      path to the html file   (default: site.html next to this file)
  THESIS_FONTS     directory with fonts    (default: fonts/ next to this file)
"""

import json
import logging
import os
import re
import tempfile
import threading
import time
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HOST = os.environ.get("THESIS_HOST", "127.0.0.1")
PORT = int(os.environ.get("THESIS_PORT", "9999"))
DATA_DIR = Path(os.environ.get("THESIS_DATA_DIR", "./data"))
SITE = Path(os.environ.get("THESIS_SITE", Path(__file__).with_name("site.html")))
FONTS = Path(os.environ.get("THESIS_FONTS", Path(__file__).with_name("fonts")))

MAX_BODY = 1_000_000          # 1 MB request cap
MAX_NOTE = 200_000            # characters per chapter note
DISCUSS_TTL = 6 * 3600        # cache good lookups for 6 h
DISCUSS_ERR_TTL = 300         # cache failures for 5 min
USER_AGENT = "thesis-textbook/1.0 (self-hosted study site)"

TASK_KEY = re.compile(r"^\d{1,3}-\d{1,3}$")
NOTE_KEY = re.compile(r"^\d{1,3}$")
SUBREDDIT = re.compile(r"^[A-Za-z0-9_]{2,21}$")
FONT_FILE = re.compile(r"^[A-Za-z0-9._-]+\.(woff2|css|txt)$")
FONT_TYPES = {"woff2": "font/woff2", "css": "text/css; charset=utf-8", "txt": "text/plain; charset=utf-8"}

log = logging.getLogger("thesis")


# --------------------------------------------------------------------------
# Persistent state
# --------------------------------------------------------------------------
class Store:
    """Thread-safe JSON store with atomic, fsync'd writes."""

    def __init__(self, directory: Path):
        self.dir = directory
        self.dir.mkdir(parents=True, exist_ok=True)
        self.path = self.dir / "state.json"
        self.lock = threading.Lock()
        self.data = {"tasks": {}, "notes": {}}
        if self.path.exists():
            try:
                loaded = json.loads(self.path.read_text("utf-8"))
                self.data["tasks"] = dict(loaded.get("tasks", {}))
                self.data["notes"] = dict(loaded.get("notes", {}))
            except Exception:
                # Keep the broken file around rather than silently destroying it
                backup = self.path.with_suffix(f".corrupt-{int(time.time())}")
                self.path.rename(backup)
                log.error("state.json unreadable, moved to %s", backup)

    def _flush(self):
        fd, tmp = tempfile.mkstemp(dir=self.dir, prefix=".state-", suffix=".tmp")
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as f:
                json.dump(self.data, f, ensure_ascii=False, indent=1)
                f.flush()
                os.fsync(f.fileno())
            os.replace(tmp, self.path)
        except Exception:
            try:
                os.unlink(tmp)
            except OSError:
                pass
            raise

    def snapshot(self):
        with self.lock:
            return {
                "tasks": dict(self.data["tasks"]),
                "notes": {k: v["text"] for k, v in self.data["notes"].items()},
            }

    def set_task(self, key: str, done: bool):
        with self.lock:
            if done:
                self.data["tasks"][key] = True
            else:
                self.data["tasks"].pop(key, None)
            self._flush()

    def set_note(self, key: str, text: str):
        with self.lock:
            if text.strip():
                self.data["notes"][key] = {"text": text, "updated": int(time.time())}
            else:
                self.data["notes"].pop(key, None)
            self._flush()

    def replace_tasks(self, keys):
        with self.lock:
            self.data["tasks"] = {k: True for k in keys}
            self._flush()


# --------------------------------------------------------------------------
# Hacker News / Reddit lookups (cached on disk + memory)
# --------------------------------------------------------------------------
class Discuss:
    def __init__(self, directory: Path):
        self.path = directory / "discuss_cache.json"
        self.lock = threading.Lock()
        self.cache = {}
        if self.path.exists():
            try:
                self.cache = json.loads(self.path.read_text("utf-8"))
            except Exception:
                self.cache = {}

    def _persist(self):
        try:
            good = {k: v for k, v in self.cache.items() if v.get("ok")}
            fd, tmp = tempfile.mkstemp(dir=self.path.parent, prefix=".disc-", suffix=".tmp")
            with os.fdopen(fd, "w", encoding="utf-8") as f:
                json.dump(good, f)
            os.replace(tmp, self.path)
        except Exception as e:  # cache only, never fatal
            log.warning("could not persist discuss cache: %s", e)

    @staticmethod
    def _get_json(url: str):
        req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=8) as r:
            return json.loads(r.read().decode("utf-8"))

    def _fetch_hn(self, q: str):
        url = "https://hn.algolia.com/api/v1/search?" + urllib.parse.urlencode(
            {"query": q, "tags": "story", "hitsPerPage": 15, "numericFilters": "points>10"}
        )
        out = []
        for h in self._get_json(url).get("hits", []):
            if not h.get("title"):
                continue
            hn_url = f"https://news.ycombinator.com/item?id={h['objectID']}"
            out.append({
                "title": h["title"],
                "url": hn_url,                       # discussion page
                "link": h.get("url") or hn_url,      # the article itself
                "score": h.get("points") or 0,
                "comments": h.get("num_comments") or 0,
                "meta": (h.get("created_at") or "")[:4],
            })
        return out

    def _fetch_reddit(self, q: str, sub: str):
        base = f"https://www.reddit.com/r/{sub}/search.json" if sub else "https://www.reddit.com/search.json"
        params = {"q": q, "sort": "top", "t": "all", "limit": 15, "raw_json": 1}
        if sub:
            params["restrict_sr"] = 1
        out = []
        for c in self._get_json(base + "?" + urllib.parse.urlencode(params)).get("data", {}).get("children", []):
            d = c.get("data", {})
            if not d.get("title") or d.get("over_18"):
                continue
            out.append({
                "title": d["title"],
                "url": "https://www.reddit.com" + d["permalink"],
                "link": "https://www.reddit.com" + d["permalink"],
                "score": d.get("score") or 0,
                "comments": d.get("num_comments") or 0,
                "meta": "r/" + d.get("subreddit", ""),
            })
        return out

    def get(self, src: str, q: str, sub: str = ""):
        """Return (items, ok)."""
        key = f"{src}|{sub}|{q}".lower()
        now = time.time()
        with self.lock:
            hit = self.cache.get(key)
        if hit and now - hit["t"] < (DISCUSS_TTL if hit["ok"] else DISCUSS_ERR_TTL):
            return hit["items"], hit["ok"]
        try:
            items = self._fetch_hn(q) if src == "hn" else self._fetch_reddit(q, sub)
            with self.lock:
                self.cache[key] = {"t": now, "ok": True, "items": items}
                self._persist()
            return items, True
        except Exception as e:
            log.warning("discuss fetch failed (%s %r): %s", src, q, e)
            if hit and hit.get("items"):          # serve stale rather than nothing
                return hit["items"], True
            with self.lock:
                self.cache[key] = {"t": now, "ok": False, "items": []}
            return [], False


store = None      # type: Store
discuss = None    # type: Discuss


# --------------------------------------------------------------------------
# HTTP
# --------------------------------------------------------------------------
class Handler(BaseHTTPRequestHandler):
    server_version = "thesis/1.0"

    # -- helpers ----------------------------------------------------------
    def _send(self, code, body: bytes, ctype="application/json; charset=utf-8", extra=None,
              cache="no-store"):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", cache)
        self.send_header("X-Content-Type-Options", "nosniff")
        for k, v in (extra or {}).items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def _json(self, code, obj):
        self._send(code, json.dumps(obj, ensure_ascii=False).encode("utf-8"))

    def _err(self, code, msg):
        self._json(code, {"error": msg})

    def _body(self):
        try:
            n = int(self.headers.get("Content-Length") or 0)
        except ValueError:
            n = 0
        if n > MAX_BODY:
            raise ValueError("body too large")
        raw = self.rfile.read(n) if n else b"{}"
        obj = json.loads(raw.decode("utf-8") or "{}")
        if not isinstance(obj, dict):
            raise ValueError("expected JSON object")
        return obj

    # -- routes -----------------------------------------------------------
    def do_GET(self):
        url = urllib.parse.urlsplit(self.path)
        path = url.path

        if path in ("/", "/index.html"):
            try:
                self._send(200, SITE.read_bytes(), "text/html; charset=utf-8")
            except OSError:
                self._err(500, "site.html not found")
        elif path.startswith("/fonts/"):
            name = path[len("/fonts/"):]
            if not FONT_FILE.match(name):
                return self._err(404, "not found")
            try:
                body = (FONTS / name).read_bytes()
            except OSError:
                return self._err(404, "not found")
            self._send(200, body, FONT_TYPES[name.rsplit(".", 1)[1]],
                       cache="public, max-age=2592000, immutable")
        elif path == "/api/state":
            self._json(200, store.snapshot())
        elif path == "/api/discuss":
            qs = urllib.parse.parse_qs(url.query)
            src = (qs.get("src") or [""])[0]
            q = (qs.get("q") or [""])[0].strip()
            sub = (qs.get("sub") or [""])[0].strip()
            if src not in ("hn", "reddit") or not q or len(q) > 100:
                return self._err(400, "bad parameters")
            if sub and not SUBREDDIT.match(sub):
                return self._err(400, "bad subreddit")
            items, ok = discuss.get(src, q, sub)
            self._json(200, {"ok": ok, "items": items})
        elif path == "/healthz":
            self._json(200, {"ok": True})
        else:
            self._err(404, "not found")

    def do_PUT(self):
        path = urllib.parse.urlsplit(self.path).path
        try:
            body = self._body()
        except Exception as e:
            return self._err(400, str(e))

        if path == "/api/task":
            key = str(body.get("key", ""))
            if not TASK_KEY.match(key):
                return self._err(400, "bad task key")
            store.set_task(key, bool(body.get("done")))
            return self._json(200, {"ok": True})

        m = re.fullmatch(r"/api/note/(\d{1,3})", path)
        if m and NOTE_KEY.match(m.group(1)):
            text = body.get("text", "")
            if not isinstance(text, str) or len(text) > MAX_NOTE:
                return self._err(400, "bad note")
            store.set_note(m.group(1), text)
            return self._json(200, {"ok": True, "saved": int(time.time())})

        self._err(404, "not found")

    def do_POST(self):
        path = urllib.parse.urlsplit(self.path).path
        try:
            body = self._body()
        except Exception as e:
            return self._err(400, str(e))

        if path == "/api/progress/reset":
            store.replace_tasks([])
            return self._json(200, {"ok": True})
        self._err(404, "not found")

    def log_message(self, fmt, *args):
        log.info("%s - %s", self.address_string(), fmt % args)


def main():
    global store, discuss
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    store = Store(DATA_DIR)
    discuss = Discuss(DATA_DIR)
    srv = ThreadingHTTPServer((HOST, PORT), Handler)
    srv.daemon_threads = True
    log.info("serving %s on http://%s:%d  (data: %s)", SITE, HOST, PORT, DATA_DIR.resolve())
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()

