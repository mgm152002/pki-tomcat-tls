# PKI with Root CA, Signing CA and a TLS certificate for Tomcat

A two-tier PKI built with OpenSSL, following the "Simple PKI" layout of the
[OpenSSL PKI Tutorial](https://pki-tutorial.readthedocs.io/en/latest/simple/), and used to
serve Apache Tomcat over HTTPS as in the
[Tomcat SSL/TLS how-to](https://tomcat.apache.org/tomcat-10.1-doc/ssl-howto.html).

```
Simple Root CA  (self-signed, RSA 4096, 10 y)        -> crl/root-ca.crl
 └── Simple Signing CA  (RSA 3072, 10 y, pathlen:0)  -> crl/signing-ca.crl
      ├── localhost            (RSA 2048, 2 y, SAN DNS:localhost, IP:127.0.0.1) -> Tomcat :8443
      └── revoked.simple.org   (revoked, reason superseded; revocation demo)
```

Tested with OpenSSL 3.0.13, OpenJDK 21 and Apache Tomcat 10.1.62 on Linux.

## Layout

| Path | What it is |
|---|---|
| `etc/root-ca.conf` | Root CA config: DN, policy, `root_ca_ext`, `signing_ca_ext`, CRL settings |
| `etc/signing-ca.conf` | Signing CA config: issues `server_ext` certs, copies SAN from the CSR |
| `etc/server.conf` | TLS server CSR template; SAN comes from the `SAN` env var |
| `scripts/01-root-ca.sh` … `05-revocation-demo.sh` | Build the PKI step by step |
| `scripts/06-install-tomcat.sh` | Download Tomcat from archive.apache.org and check its SHA-512 |
| `scripts/07-configure-tomcat.sh` | Copy the keystore, add the HTTPS connector, install the demo page |
| `scripts/08-verify.sh` | `s_client -showcerts`, `openssl verify`, `curl --cacert` checks |
| `tomcat/https-connector.xml` | The connector added to `server.xml` (PKCS#12 keystore) |
| `tomcat/https-connector-pem.xml` | Alternative connector using PEM files directly |
| `tomcat/server.xml` | The full `server.xml` as configured |
| `tomcat/index.jsp` | Demo page that prints the TLS protocol and cipher |
| `docs/certs/` | Public outputs only: CA certs, server cert, chain, CRLs |
| `docs/outputs/` | Captured output of every script run |
| `docs/figures/` | Figures used in the report |

Private keys, CA databases and keystores are generated into `ca/`, `certs/` and `crl/`, which are git-ignored.

## Run it

```bash
bash scripts/build-all.sh          # Root CA, Signing CA, TLS cert, keystore, revocation demo
bash scripts/06-install-tomcat.sh  # Tomcat 10.1.62 (override with TOMCAT_VERSION=...)
bash scripts/07-configure-tomcat.sh
bash scripts/tomcat-start.sh
bash scripts/08-verify.sh
bash scripts/tomcat-stop.sh
```

Passphrases default to demo values in `scripts/env.sh`. Set `ROOT_CA_PASS`, `SIGNING_CA_PASS`
and `KEYSTORE_PASS` in the environment to use your own. `bash scripts/clean.sh` deletes all
generated PKI material so you can start over.

## Trusting the Root CA in a browser

Import `ca/root-ca.crt` (or `docs/certs/root-ca.crt`) as a trusted authority, then open
`https://localhost:8443/`. The browser shows the chain localhost → Simple Signing CA → Simple Root CA.

- Chrome / Edge on Windows: `certmgr.msc` → Trusted Root Certification Authorities → Import.
- macOS: Keychain Access → System → import, then set *When using this certificate* to *Always Trust*.
- Firefox: Settings → Privacy & Security → Certificates → View Certificates → Authorities → Import.

## Key commands

```bash
# Root CA (self-signed)
openssl req -new -config etc/root-ca.conf -out ca/root-ca.csr -keyout ca/root-ca/private/root-ca.key
openssl ca -selfsign -config etc/root-ca.conf -in ca/root-ca.csr -out ca/root-ca.crt -extensions root_ca_ext

# Signing CA (signed by Root CA)
openssl req -new -config etc/signing-ca.conf -out ca/signing-ca.csr -keyout ca/signing-ca/private/signing-ca.key
openssl ca -config etc/root-ca.conf -in ca/signing-ca.csr -out ca/signing-ca.crt -extensions signing_ca_ext

# TLS server certificate (signed by Signing CA)
SAN=DNS:localhost,IP:127.0.0.1 openssl req -new -config etc/server.conf -out certs/localhost.csr -keyout certs/localhost.key
openssl ca -config etc/signing-ca.conf -in certs/localhost.csr -out certs/localhost.crt -extensions server_ext

# PKCS#12 keystore for Tomcat
openssl pkcs12 -export -name tomcat -inkey certs/localhost.key -in certs/localhost.crt \
    -certfile ca/signing-ca-chain.pem -out certs/localhost.p12

# Revoke and publish a CRL
openssl ca -config etc/signing-ca.conf -revoke ca/signing-ca/02.pem -crl_reason superseded
openssl ca -gencrl -config etc/signing-ca.conf -out crl/signing-ca.crl
```
