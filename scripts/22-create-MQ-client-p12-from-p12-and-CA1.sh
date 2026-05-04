#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mqclient-p12

openssl pkcs12 -chain -certfile generated-output/ace-demo-CA1/ace-demo-CA1.crt -CAfile generated-output/ace-demo-CA1/ace-demo-CA1.crt -inkey generated-output/mqclient-keys/mqclient.key -in generated-output/mqclient-keys/mqclient.crt -export -out generated-output/mqclient-p12/mqclient-plus-CA1.p12 -passin pass:changeit -passout pass:changeit -legacy

# OpenSSL doesn't seem to be copying the CA cert into the keystore correctly despite the "-chain" and other CA-related parameters
/opt/mqm/bin/runmqakm -cert -add -db generated-output/mqclient-p12/mqclient-plus-CA1.p12 -pw changeit -file generated-output/ace-demo-CA1/ace-demo-CA1.crt

/opt/mqm/bin/runmqakm -cert -list -db generated-output/mqclient-p12/mqclient-plus-CA1.p12 -pw changeit
