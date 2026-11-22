#!/usr/bin/env bash
# Run the whole PKI build: Root CA -> Signing CA -> TLS cert -> keystore -> revocation demo.
set -euo pipefail
DIR="$(dirname "$0")"
bash "$DIR/01-root-ca.sh"
bash "$DIR/02-signing-ca.sh"
bash "$DIR/03-server-cert.sh"
bash "$DIR/04-tomcat-keystore.sh"
bash "$DIR/05-revocation-demo.sh"
