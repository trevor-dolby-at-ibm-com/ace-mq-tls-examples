#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/ace-p12

openssl pkcs12 -chain -certfile generated-output/ace-demo-CA1/ace-demo-CA1.crt -CAfile generated-output/ace-demo-CA2/ace-demo-CA2.crt -inkey generated-output/aceclient-keys/aceclient.key -in generated-output/aceclient-keys/aceclient.crt -export -out generated-output/ace-p12/aceclient-plus-CA1.p12 -passin pass:changeit -passout pass:changeit

/opt/mqm/bin/runmqakm -cert -list -db generated-output/ace-p12/aceclient-plus-CA1.p12 -pw changeit
