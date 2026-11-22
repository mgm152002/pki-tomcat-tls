#!/usr/bin/env bash
# Step 3: issue the TLS server certificate from the Signing CA.
set -euo pipefail
source "$(dirname "$0")/env.sh"
NAME="${1:-$SERVER_CN}"
SAN="${2:-$SERVER_SAN}"
export SAN

echo "== 3.1 Create TLS server request for CN=$NAME, SAN=$SAN"
openssl req -new \
    -config etc/server.conf \
    -out "certs/$NAME.csr" \
    -keyout "certs/$NAME.key" \
    -subj "/DC=org/DC=simple/O=Simple Inc/OU=Simple Web/CN=$NAME"
chmod 600 "certs/$NAME.key"

echo "== 3.2 Create TLS server certificate (signed by Signing CA)"
openssl ca -batch \
    -config etc/signing-ca.conf \
    -in "certs/$NAME.csr" \
    -out "certs/$NAME.crt" \
    -extensions server_ext \
    -passin env:SIGNING_CA_PASS

echo "== 3.3 Build full chain (server + Signing CA + Root CA)"
cat "certs/$NAME.crt" ca/signing-ca.crt ca/root-ca.crt > "certs/$NAME-fullchain.pem"

echo "== Server certificate:"
openssl x509 -in "certs/$NAME.crt" -noout -subject -issuer -serial -dates -ext subjectAltName,keyUsage,extendedKeyUsage,basicConstraints
openssl verify -CAfile ca/root-ca.crt -untrusted ca/signing-ca.crt "certs/$NAME.crt"
