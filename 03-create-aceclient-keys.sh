#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

# CN=aceclient,OU=ExpertLabs,O=IBM,L=Minneapolis,ST=MN,C=US 
mkdir generated-output/aceclient-keys
openssl req -newkey rsa:4096 -subj "/C=US/ST=MN/L=Minneapolis/O=IBM/OU=ExpertLabs/CN=aceclient"  -keyout generated-output/aceclient-keys/aceclient.key -out generated-output/aceclient-keys/aceclient.csr -passout pass:changeit

openssl x509 -req -CA generated-output/ace-demo-CA2/ace-demo-CA2.crt -CAkey generated-output/ace-demo-CA2/ace-demo-CA2.key -in generated-output/aceclient-keys/aceclient.csr -out generated-output/aceclient-keys/aceclient.crt -days 365 -CAcreateserial  -passin pass:changeit
openssl x509 -in generated-output/aceclient-keys/aceclient.crt -outform der -out generated-output/aceclient-keys/aceclient.der

openssl pkcs12 -chain -CAfile generated-output/ace-demo-CA2/ace-demo-CA2.crt -inkey generated-output/aceclient-keys/aceclient.key -in generated-output/aceclient-keys/aceclient.crt -export -out generated-output/aceclient-keys/aceclient.p12 -passin pass:changeit -passout pass:changeit  -legacy

cat generated-output/aceclient-keys/aceclient.key | openssl rsa -noout -text -passin pass:changeit
cat generated-output/aceclient-keys/aceclient.crt | openssl x509 -noout -text

/opt/mqm/bin/runmqakm -cert -list -db generated-output/aceclient-keys/aceclient.p12 -pw changeit
