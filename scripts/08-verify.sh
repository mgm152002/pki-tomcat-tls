#!/usr/bin/env bash
# Step 8: verify the running Tomcat presents the right chain and that clients trusting
# only the Root CA accept it.
set -euo pipefail
source "$(dirname "$0")/env.sh"
HOST=localhost; PORT=8443

echo "== 8.1 openssl s_client -showcerts (chain sent by Tomcat)"
openssl s_client -connect $HOST:$PORT -servername $HOST -showcerts -CAfile ca/root-ca.crt </dev/null 2>/dev/null \
    | grep -E '^ *[0-9] s:|^ *i:|^---$|Verification|Verify return code|Protocol|Cipher|Server certificate' | head -30

echo "== 8.2 openssl verify of the certificate Tomcat served"
openssl s_client -connect $HOST:$PORT -servername $HOST </dev/null 2>/dev/null | openssl x509 -out /tmp/served.crt
openssl verify -CAfile ca/root-ca.crt -untrusted ca/signing-ca.crt /tmp/served.crt
openssl x509 -in /tmp/served.crt -noout -subject -issuer -serial

echo "== 8.3 curl trusting only the Root CA"
curl --noproxy "*" -sS -v --cacert ca/root-ca.crt https://$HOST:$PORT/ -o /tmp/page.html 2>&1 \
    | grep -E 'SSL connection|server certificate|subject:|issuer:|expire date|subjectAltName|SSL certificate verify|HTTP/1.1 200' 
echo "-- page title: $(grep -o '<h1>.*</h1>' /tmp/page.html)"

echo "== 8.4 curl via 127.0.0.1 (matches the IP SAN)"
curl --noproxy "*" -sS --cacert ca/root-ca.crt -o /dev/null -w 'HTTP %{http_code}, verify result %{ssl_verify_result}\n' https://127.0.0.1:$PORT/

echo "== 8.5 curl WITHOUT our Root CA (should fail: unknown issuer)"
curl --noproxy "*" -sS https://$HOST:$PORT/ -o /dev/null 2>&1 || true
