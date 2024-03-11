#!/bin/bash

INFRA_DIR="infrastructure/pulsar"

docker compose --project-name pulsar --file $INFRA_DIR/cluster.yaml up -d