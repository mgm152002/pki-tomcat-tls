#!/usr/bin/env bash
# Start Tomcat and wait for the HTTPS connector to come up.
set -euo pipefail
source "$(dirname "$0")/env.sh"
"$TOMCAT_HOME/bin/startup.sh"
for i in $(seq 1 30); do
  if grep -q 'Server startup in' "$TOMCAT_HOME/logs/catalina.out" 2>/dev/null; then break; fi
  sleep 1
done
grep -E 'Server version name|Connector \[https-jsse-nio-8443\]|ProtocolHandler \["https-jsse-nio-8443"\]|TLS virtual host|Server startup in' "$TOMCAT_HOME/logs/catalina.out" | sed 's/^[0-9-]* [0-9:.]* //'
