#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
"$TOMCAT_HOME/bin/shutdown.sh"
