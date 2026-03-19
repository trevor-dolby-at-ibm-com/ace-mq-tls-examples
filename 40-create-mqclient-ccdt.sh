#!/bin/bash

# Exit on error
set -e
# Log everything
set -x

mkdir generated-output/mqclient-ccdt

export MQCHLLIB=generated-output/mqclient-ccdt
cat openshift/cp4iqm-ccdt-define.mqsc | /opt/mqm/bin/runmqsc -n
