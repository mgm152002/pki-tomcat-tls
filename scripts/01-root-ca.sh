#!/usr/bin/env bash
# Step 1: create the Root CA (self-signed, offline trust anchor).
set -euo pipefail
source "$(dirname "$0")/env.sh"

echo "== 1.1 Create directories"
mkdir -p ca/root-ca/private ca/root-ca/db crl certs
chmod 700 ca/root-ca/private

echo "== 1.2 Create database"
cp /dev/null ca/root-ca/db/root-ca.db
cp /dev/null ca/root-ca/db/root-ca.db.attr
echo 01 > ca/root-ca/db/root-ca.crt.srl
echo 01 > ca/root-ca/db/root-ca.crl.srl

echo "== 1.3 Create CA request (4096-bit RSA key, AES-256 encrypted)"
openssl req -new \
    -config etc/root-ca.conf \
    -out ca/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key \
    -passout env:ROOT_CA_PASS

echo "== 1.4 Create CA certificate (self-signed, 10 years)"
openssl ca -selfsign -batch \
    -config etc/root-ca.conf \
    -in ca/root-ca.csr \
    -out ca/root-ca.crt \
    -extensions root_ca_ext \
    -passin env:ROOT_CA_PASS

echo "== Root CA certificate:"
openssl x509 -in ca/root-ca.crt -noout -subject -issuer -serial -dates -fingerprint -sha256
