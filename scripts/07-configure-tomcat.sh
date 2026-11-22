#!/usr/bin/env bash
# Step 7: copy the keystore into Tomcat, add the HTTPS connector on 8443, and a demo page.
set -euo pipefail
source "$(dirname "$0")/env.sh"

echo "== 7.1 Copy keystore to \$CATALINA_BASE/conf"
cp "certs/$SERVER_CN.p12" "$TOMCAT_HOME/conf/localhost.p12"
chmod 600 "$TOMCAT_HOME/conf/localhost.p12"

echo "== 7.2 Insert HTTPS connector into server.xml"
python3 - "$TOMCAT_HOME/conf/server.xml" "tomcat/https-connector.xml" "$KEYSTORE_PASS" <<'PY'
import sys, re
server_xml, snippet_file, password = sys.argv[1:]
xml = open(server_xml).read()
snippet = open(snippet_file).read().replace("${KEYSTORE_PASS}", password)
if "port=\"8443\"" in xml and "localhost.p12" in xml:
    print("connector already present")
else:
    # Match the real Engine element. The stock server.xml also has a commented-out
    # example "<Engine name=\"Catalina\" defaultHost=\"localhost\" jvmRoute=\"jvm1\">",
    # so matching only the start of the tag would put the connector inside a comment.
    marker = '<Engine name="Catalina" defaultHost="localhost">'
    if xml.count(marker) != 1:
        sys.exit("expected exactly one active <Engine> element")
    xml = xml.replace(marker, snippet.lstrip() + "\n    " + marker, 1)
    open(server_xml, "w").write(xml)
    print("connector added")
PY
grep -n -A14 'HTTPS connector (PKI assignment)' "$TOMCAT_HOME/conf/server.xml"

echo "== 7.3 Install demo page as the ROOT web app"
rm -rf "$TOMCAT_HOME/webapps/ROOT"
mkdir -p "$TOMCAT_HOME/webapps/ROOT"
cp tomcat/index.jsp "$TOMCAT_HOME/webapps/ROOT/index.jsp"
