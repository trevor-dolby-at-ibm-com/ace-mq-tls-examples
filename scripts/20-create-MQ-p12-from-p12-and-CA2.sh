#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mq-p12

openssl pkcs12 -chain -certfile generated-output/ace-demo-CA2/ace-demo-CA2.crt -CAfile generated-output/ace-demo-CA1/ace-demo-CA1.crt -inkey generated-output/mqserver-keys/qm.key -in generated-output/mqserver-keys/qm.crt -export -out generated-output/mq-p12/qm-plus-CA2.p12 -passin pass:changeit -passout pass:changeit  -legacy

/opt/mqm/bin/runmqakm -cert -list -db generated-output/mq-p12/qm-plus-CA2.p12 -pw changeit
