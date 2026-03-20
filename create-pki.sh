#!/bin/bash

# Exit on error
set -e

scripts/01-create-demo-CAs.sh
scripts/02-create-mqserver-keys.sh
scripts/03-create-aceclient-keys.sh
scripts/04-create-mqclient-keys.sh
scripts/10-create-MQ-kdb-from-p12-and-CA2.sh
scripts/11-create-ACE-kdb-from-p12-and-CA1.sh
scripts/12-create-MQ-client-kdb-from-p12-and-CA1.sh
scripts/20-create-MQ-p12-from-p12-and-CA2.sh
scripts/21-create-ACE-p12-from-p12-and-CA1.sh
scripts/22-create-MQ-client-p12-from-p12-and-CA1.sh
scripts/40-create-mqclient-ccdt.sh
