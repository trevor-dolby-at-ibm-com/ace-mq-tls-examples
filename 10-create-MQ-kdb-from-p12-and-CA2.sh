#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mq-kdb

/opt/mqm/bin/runmqakm -keydb -convert -pw changeit -db generated-output/mqserver-keys/qm.p12 -target generated-output/mq-kdb/qm.kdb -new_format kdb -stash
/opt/mqm/bin/runmqakm -cert -add -pw changeit -db generated-output/mq-kdb/qm.kdb -file generated-output/ace-demo-CA2/ace-demo-CA2.crt
/opt/mqm/bin/runmqakm -cert -list -db generated-output/mq-kdb/qm.kdb -pw changeit -v
