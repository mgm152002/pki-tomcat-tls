#!/usr/bin/env bash
# Step 4: bundle the server key + cert + CA chain into a PKCS#12 keystore for Tomcat.
set -euo pipefail
source "$(dirname "$0")/env.sh"
NAME="${1:-$SERVER_CN}"

echo "== 4.1 Create PKCS#12 keystore (alias 'tomcat') with the full chain"
openssl pkcs12 -export \
    -name tomcat \
    -inkey "certs/$NAME.key" \
    -in "certs/$NAME.crt" \
    -certfile ca/signing-ca-chain.pem \
    -out "certs/$NAME.p12" \
    -passout env:KEYSTORE_PASS
chmod 600 "certs/$NAME.p12"

echo "== 4.2 Inspect keystore with keytool"
keytool -list -keystore "certs/$NAME.p12" -storetype PKCS12 -storepass "$KEYSTORE_PASS" -v 2>/dev/null \
    | grep -E 'Alias name|Entry type|Certificate chain length|Owner:|Issuer:'

echo "== 4.3 Create a truststore with the Root CA (for Java clients)"
rm -f certs/truststore.p12
keytool -importcert -noprompt -alias simple-root-ca -file ca/root-ca.crt \
    -keystore certs/truststore.p12 -storetype PKCS12 -storepass "$KEYSTORE_PASS" 2>/dev/null
keytool -list -keystore certs/truststore.p12 -storetype PKCS12 -storepass "$KEYSTORE_PASS" 2>/dev/null | tail -2
