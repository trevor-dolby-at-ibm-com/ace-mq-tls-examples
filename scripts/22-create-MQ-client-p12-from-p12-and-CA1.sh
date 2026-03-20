#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mqclient-p12

openssl pkcs12 -chain -certfile generated-output/ace-demo-CA1/ace-demo-CA1.crt -CAfile generated-output/ace-demo-CA1/ace-demo-CA1.crt -inkey generated-output/mqclient-keys/mqclient.key -in generated-output/mqclient-keys/mqclient.crt -export -out generated-output/mqclient-p12/mqclient-plus-CA1.p12 -passin pass:changeit -passout pass:changeit -legacy

/opt/mqm/bin/runmqakm -cert -list -db generated-output/mqclient-p12/mqclient-plus-CA1.p12 -pw changeit
