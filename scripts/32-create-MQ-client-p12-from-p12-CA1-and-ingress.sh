#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mqclient-p12-ingress


echo | openssl s_client -showcerts -servername cp4iqm-ibm-mq-qm-cp4i.apps.openshift.yourcompany.com -connect cp4iqm-ibm-mq-qm-cp4i.apps.openshift.yourcompany.com:443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > generated-output/mqclient-p12-ingress/ingress-full-chain.pem

cp generated-output/mqclient-p12/mqclient-plus-CA1.p12 generated-output/mqclient-p12-ingress/mqclient-plus-CA1-ingress.p12

keytool -importcert -keystore generated-output/mqclient-p12-ingress/mqclient-plus-CA1-ingress.p12 -storepass changeit -file generated-output/mqclient-p12-ingress/ingress-full-chain.pem -trustcacerts -noprompt

/opt/mqm/bin/runmqakm -cert -list -db generated-output/mqclient-p12-ingress/mqclient-plus-CA1-ingress.p12 -pw changeit
