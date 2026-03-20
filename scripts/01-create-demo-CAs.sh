#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/ace-demo-CA1
openssl req -x509 -passout pass:changeit -subj "/C=US/ST=MN/L=Minneapolis/O=IBM/OU=ExpertLabs/CN=ace-demo-CA1" -sha256 -days 1825 -newkey rsa:4096 -keyout generated-output/ace-demo-CA1/ace-demo-CA1.key -out generated-output/ace-demo-CA1/ace-demo-CA1.crt
cat generated-output/ace-demo-CA1/ace-demo-CA1.key | openssl rsa -noout -text -passin pass:changeit
cat generated-output/ace-demo-CA1/ace-demo-CA1.crt | openssl x509 -noout -text
mkdir generated-output/ace-demo-CA2
openssl req -x509 -passout pass:changeit -subj "/C=US/ST=MN/L=Minneapolis/O=IBM/OU=ExpertLabs/CN=ace-demo-CA2" -sha256 -days 1825 -newkey rsa:4096 -keyout generated-output/ace-demo-CA2/ace-demo-CA2.key -out generated-output/ace-demo-CA2/ace-demo-CA2.crt
cat generated-output/ace-demo-CA2/ace-demo-CA2.key | openssl rsa -noout -text -passin pass:changeit
cat generated-output/ace-demo-CA2/ace-demo-CA2.crt | openssl x509 -noout -text
