#!/bin/bash

# Exit on error
set -e

scripts/30-create-mq-tls-secret-yaml.sh
scripts/31-create-mq-tls-trust-yaml.sh
