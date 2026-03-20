#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mqserver-tls-trust

CACERT=$(cat generated-output/ace-demo-CA2/ace-demo-CA2.crt | base64 -w 0)

cat openshift/mqserver-tls-trust-template.yaml  | sed "s|CACRTBASE64|${CACERT}|g" > generated-output/mqserver-tls-trust/mqserver-tls-trust.yaml
