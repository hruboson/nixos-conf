{ self, inputs, ... }:
{
  flake.nixosModules.selfhostedCertificate =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      certificate = "-----BEGIN CERTIFICATE-----
MIIBojCCAUmgAwIBAgIQM00m2FQFjcxmD+KhP1pJQTAKBggqhkjOPQQDAjAwMS4w
LAYDVQQDEyVDYWRkeSBMb2NhbCBBdXRob3JpdHkgLSAyMDI2IEVDQyBSb290MB4X
DTI2MDgyMzE3MjkxNloXDTM2MDcwMTE3MjkxNlowMDEuMCwGA1UEAxMlQ2FkZHkg
TG9jYWwgQXV0aG9yaXR5IC0gMjAyNiBFQ0MgUm9vdDBZMBMGByqGSM49AgEGCCqG
SM49AwEHA0IABFVp/UeLa/e8MN99basDyA3TzzMiG2jbgqcXbfvSDBkRYXPR1qdR
+MF2rZ2H9clvO7/mZZ3SMGIKCQomeuR9jVejRTBDMA4GA1UdDwEB/wQEAwIBBjAS
BgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBTYCTAO472SbrsZfkQsDPp76lG8
VDAKBggqhkjOPQQDAgNHADBEAiABidnZa/Pexb2dYRE9EfrKztN004MDzcgeIuhF
htCvzwIgK+xOhPzctAe+Mm6EB6ZJXJGEzP7NH8dvPrPK/E02RgU=
-----END CERTIFICATE-----";

      server = pkgs.writeText "certificate-server.py" ''
        from http.server import BaseHTTPRequestHandler, HTTPServer

        CERTIFICATE = b"""${certificate}"""

        class Handler(BaseHTTPRequestHandler):
            def do_GET(self):
                if self.path != "/":
                    self.send_error(404)
                    return

                self.send_response(200)
                self.send_header(
                    "Content-Type",
                    "application/x-x509-ca-cert"
                )
                self.send_header(
                    "Content-Disposition",
                    'attachment; filename="certificate.crt"'
                )
                self.send_header(
                    "Content-Length",
                    str(len(CERTIFICATE))
                )
                self.end_headers()
                self.wfile.write(CERTIFICATE)

            def log_message(self, format, *args):
                print(format % args)

        server = HTTPServer(("0.0.0.0", 1234), Handler)
        server.serve_forever()
      '';
    in
    {
      systemd.services.selfhosted-certificate = {
        description = "Static certificate HTTP server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.python3}/bin/python3 ${server}";
          Restart = "always";

          DynamicUser = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
        };
      };

      networking.firewall.allowedTCPPorts = [ 1234 ];
    };
}
