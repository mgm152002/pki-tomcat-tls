#!/usr/bin/env bash
# Step 5: revocation demo. Issue a throw-away cert, revoke it, publish a new CRL,
# and show that CRL-checking verification rejects it while the real server cert still passes.
set -euo pipefail
source "$(dirname "$0")/env.sh"
NAME=revoked.simple.org

echo "== 5.1 Issue a second TLS certificate ($NAME)"
SAN="DNS:$NAME" bash scripts/03-server-cert.sh "$NAME" "DNS:$NAME" > /dev/null
SERIAL=$(openssl x509 -in "certs/$NAME.crt" -noout -serial | cut -d= -f2)
echo "Issued $NAME with serial $SERIAL"

echo "== 5.2 Revoke it (reason: superseded)"
openssl ca -config etc/signing-ca.conf \
    -revoke "ca/signing-ca/$SERIAL.pem" \
    -crl_reason superseded \
    -passin env:SIGNING_CA_PASS

echo "== 5.3 Publish a new Signing CA CRL"
openssl ca -gencrl -config etc/signing-ca.conf -out crl/signing-ca.crl -passin env:SIGNING_CA_PASS
openssl crl -in crl/signing-ca.crl -noout -text | sed -n '1,25p'

echo "== 5.4 Signing CA database (V = valid, R = revoked)"
cat ca/signing-ca/db/signing-ca.db

echo "== 5.5 Verify with CRL checking"
cat ca/root-ca.crt crl/root-ca.crl ca/signing-ca.crt crl/signing-ca.crl > crl/ca-chain-with-crls.pem
echo "-- $SERVER_CN (should be OK):"
openssl verify -crl_check_all -CAfile crl/ca-chain-with-crls.pem "certs/$SERVER_CN.crt" || true
echo "-- $NAME (should be revoked):"
openssl verify -crl_check_all -CAfile crl/ca-chain-with-crls.pem "certs/$NAME.crt" || true
