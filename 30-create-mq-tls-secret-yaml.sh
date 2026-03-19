#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mqserver-tls-secret


MQSERVERKEY=$(cat generated-output/mqserver-keys/qm-decrypted.key | base64 -w 0)
MQSERVERCERT=$(cat generated-output/mqserver-keys/qm.crt | base64 -w 0)
CACERT=$(cat generated-output/ace-demo-CA1/ace-demo-CA1.crt | base64 -w 0)

cat openshift/mqserver-tls-secret-template.yaml  | sed "s|CACRTBASE64|${CACERT}|g" | sed "s|TLSKEYBASE64|${MQSERVERKEY}|g" | sed "s|TLSCRTBASE64|${MQSERVERCERT}|g" > generated-output/mqserver-tls-secret/mqserver-tls-secret.yaml
