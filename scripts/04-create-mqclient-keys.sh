#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

# CN=mqclient,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US 
mkdir generated-output/mqclient-keys
openssl req -newkey rsa:4096 -subj "/C=US/ST=MN/L=Minneapolis/O=IBM/OU=ExpertLabs/CN=mqclient"  -keyout generated-output/mqclient-keys/mqclient.key -out generated-output/mqclient-keys/mqclient.csr -passout pass:changeit

openssl x509 -req -CA generated-output/ace-demo-CA1/ace-demo-CA1.crt -CAkey generated-output/ace-demo-CA1/ace-demo-CA1.key -in generated-output/mqclient-keys/mqclient.csr -out generated-output/mqclient-keys/mqclient.crt -days 365 -CAcreateserial  -passin pass:changeit
openssl x509 -in generated-output/mqclient-keys/mqclient.crt -outform der -out generated-output/mqclient-keys/mqclient.der

openssl rsa -out generated-output/mqclient-keys/mqclient-decrypted.key -in generated-output/mqclient-keys/mqclient.key -passin pass:changeit

openssl pkcs12 -chain -CAfile generated-output/ace-demo-CA1/ace-demo-CA1.crt -inkey generated-output/mqclient-keys/mqclient.key -in generated-output/mqclient-keys/mqclient.crt -export -out generated-output/mqclient-keys/mqclient.p12 -passin pass:changeit -passout pass:changeit  -legacy

cat generated-output/mqclient-keys/mqclient.key | openssl rsa -noout -text -passin pass:changeit
cat generated-output/mqclient-keys/mqclient.crt | openssl x509 -noout -text

/opt/mqm/bin/runmqakm -cert -list -db generated-output/mqclient-keys/mqclient.p12 -pw changeit
