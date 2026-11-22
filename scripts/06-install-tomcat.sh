#!/usr/bin/env bash
# Step 6: download Apache Tomcat from the Apache archive, check its SHA-512, and unpack it.
set -euo pipefail
source "$(dirname "$0")/env.sh"
BASE="https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION%%.*}/v$TOMCAT_VERSION/bin"
TGZ="apache-tomcat-$TOMCAT_VERSION.tar.gz"

mkdir -p downloads
echo "== 6.1 Download $TGZ"
[ -f "downloads/$TGZ" ] || curl -fsSL -o "downloads/$TGZ" "$BASE/$TGZ"
curl -fsSL -o "downloads/$TGZ.sha512" "$BASE/$TGZ.sha512"

echo "== 6.2 Verify SHA-512"
(cd downloads && sha512sum -c "$TGZ.sha512")

echo "== 6.3 Unpack to $TOMCAT_HOME"
rm -rf "$TOMCAT_HOME"
tar -xzf "downloads/$TGZ" -C "$PKI_HOME"
"$TOMCAT_HOME/bin/version.sh" | grep -E 'Server version|JVM Version|OS Name'
