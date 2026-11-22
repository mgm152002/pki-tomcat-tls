#!/usr/bin/env bash
# Step 2: create the Signing CA, signed by the Root CA.
set -euo pipefail
source "$(dirname "$0")/env.sh"

echo "== 2.1 Create directories"
mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
chmod 700 ca/signing-ca/private

echo "== 2.2 Create database"
cp /dev/null ca/signing-ca/db/signing-ca.db
cp /dev/null ca/signing-ca/db/signing-ca.db.attr
echo 01 > ca/signing-ca/db/signing-ca.crt.srl
echo 01 > ca/signing-ca/db/signing-ca.crl.srl

echo "== 2.3 Create CA request (3072-bit RSA key, AES-256 encrypted)"
openssl req -new \
    -config etc/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key \
    -passout env:SIGNING_CA_PASS

echo "== 2.4 Create CA certificate (signed by Root CA, pathlen:0)"
openssl ca -batch \
    -config etc/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext \
    -passin env:ROOT_CA_PASS

echo "== 2.5 Create initial CRLs"
openssl ca -gencrl -config etc/root-ca.conf    -out crl/root-ca.crl    -passin env:ROOT_CA_PASS
openssl ca -gencrl -config etc/signing-ca.conf -out crl/signing-ca.crl -passin env:SIGNING_CA_PASS

echo "== 2.6 Create CA chain file (Signing CA + Root CA)"
cat ca/signing-ca.crt ca/root-ca.crt > ca/signing-ca-chain.pem

echo "== Signing CA certificate:"
openssl x509 -in ca/signing-ca.crt -noout -subject -issuer -serial -dates
openssl verify -CAfile ca/root-ca.crt ca/signing-ca.crt
