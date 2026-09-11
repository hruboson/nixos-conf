{ self, inputs, ... }: {
  flake.nixosModules.servicesPackHomeserver =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      security.pki.certificates = [
        "-----BEGIN CERTIFICATE-----
MIIBojCCAUmgAwIBAgIQM00m2FQFjcxmD+KhP1pJQTAKBggqhkjOPQQDAjAwMS4w
LAYDVQQDEyVDYWRkeSBMb2NhbCBBdXRob3JpdHkgLSAyMDI2IEVDQyBSb290MB4X
DTI2MDgyMzE3MjkxNloXDTM2MDcwMTE3MjkxNlowMDEuMCwGA1UEAxMlQ2FkZHkg
TG9jYWwgQXV0aG9yaXR5IC0gMjAyNiBFQ0MgUm9vdDBZMBMGByqGSM49AgEGCCqG
SM49AwEHA0IABFVp/UeLa/e8MN99basDyA3TzzMiG2jbgqcXbfvSDBkRYXPR1qdR
+MF2rZ2H9clvO7/mZZ3SMGIKCQomeuR9jVejRTBDMA4GA1UdDwEB/wQEAwIBBjAS
BgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBTYCTAO472SbrsZfkQsDPp76lG8
VDAKBggqhkjOPQQDAgNHADBEAiABidnZa/Pexb2dYRE9EfrKztN004MDzcgeIuhF
htCvzwIgK+xOhPzctAe+Mm6EB6ZJXJGEzP7NH8dvPrPK/E02RgU=
-----END CERTIFICATE-----"
      ];

      services.avahi = {
        # enables .local address resolution
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        ipv4 = true;
        ipv6 = true;
      };
    };
}
