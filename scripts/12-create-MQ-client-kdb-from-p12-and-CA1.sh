#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mqclient-kdb

/opt/mqm/bin/runmqakm -keydb -convert -pw changeit -db generated-output/mqclient-keys/mqclient.p12 -target generated-output/mqclient-kdb/mqclient.kdb -new_format kdb -stash
/opt/mqm/bin/runmqakm -cert -add -pw changeit -db generated-output/mqclient-kdb/mqclient.kdb -file generated-output/ace-demo-CA1/ace-demo-CA1.crt
/opt/mqm/bin/runmqakm -cert -list -db generated-output/mqclient-kdb/mqclient.kdb -pw changeit -v
