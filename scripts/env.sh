#!/usr/bin/env bash
# Shared settings. Override any of these by exporting them before running a script.
# The defaults are DEMO passphrases for a lab PKI only. Use real secrets for anything else.
export PKI_HOME="${PKI_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export ROOT_CA_PASS="${ROOT_CA_PASS:-root-ca-demo-pass}"
export SIGNING_CA_PASS="${SIGNING_CA_PASS:-signing-ca-demo-pass}"
export KEYSTORE_PASS="${KEYSTORE_PASS:-changeit}"
export SERVER_CN="${SERVER_CN:-localhost}"
export SERVER_SAN="${SERVER_SAN:-DNS:localhost,IP:127.0.0.1}"
export TOMCAT_VERSION="${TOMCAT_VERSION:-10.1.62}"
export TOMCAT_HOME="${TOMCAT_HOME:-$PKI_HOME/apache-tomcat-$TOMCAT_VERSION}"
cd "$PKI_HOME"
