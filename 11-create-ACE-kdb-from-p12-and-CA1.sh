#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/ace-kdb

/opt/mqm/bin/runmqakm -keydb -convert -pw changeit -db generated-output/aceclient-keys/aceclient.p12 -target generated-output/ace-kdb/aceclient.kdb -new_format kdb -stash
/opt/mqm/bin/runmqakm -cert -add -pw changeit -db generated-output/ace-kdb/aceclient.kdb -file generated-output/ace-demo-CA1/ace-demo-CA1.crt
/opt/mqm/bin/runmqakm -cert -list -db generated-output/ace-kdb/aceclient.kdb -pw changeit -v
