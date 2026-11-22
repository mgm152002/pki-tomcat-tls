#!/usr/bin/env bash
# Remove every generated key, cert, CRL and database so the PKI can be rebuilt from scratch.
set -euo pipefail
source "$(dirname "$0")/env.sh"
rm -rf ca certs crl
echo "Removed ca/, certs/, crl/"
