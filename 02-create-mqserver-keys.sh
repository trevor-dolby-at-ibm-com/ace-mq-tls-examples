#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

# CN=mqserver,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US
mkdir generated-output/mqserver-keys
openssl req -newkey rsa:4096 -subj "/C=US/ST=MN/L=Minneapolis/O=IBM/OU=ExpertLabs/CN=mqserver"  -keyout generated-output/mqserver-keys/qm.key -out generated-output/mqserver-keys/qm.csr -passout pass:changeit

openssl x509 -req -CA generated-output/ace-demo-CA1/ace-demo-CA1.crt -CAkey generated-output/ace-demo-CA1/ace-demo-CA1.key -in generated-output/mqserver-keys/qm.csr -out generated-output/mqserver-keys/qm.crt -days 365 -CAcreateserial  -passin pass:changeit
openssl x509 -in generated-output/mqserver-keys/qm.crt -outform der -out generated-output/mqserver-keys/qm.der

openssl pkcs12 -chain -CAfile generated-output/ace-demo-CA1/ace-demo-CA1.crt -inkey generated-output/mqserver-keys/qm.key -in generated-output/mqserver-keys/qm.crt -export -out generated-output/mqserver-keys/qm.p12 -passin pass:changeit -passout pass:changeit  -legacy

cat generated-output/mqserver-keys/qm.key | openssl rsa -noout -text -passin pass:changeit
cat generated-output/mqserver-keys/qm.crt | openssl x509 -noout -text

/opt/mqm/bin/runmqakm -cert -list -db generated-output/mqserver-keys/qm.p12 -pw changeit
