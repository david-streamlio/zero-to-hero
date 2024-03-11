#!/bin/bash

INFRA_DIR="infrastructure/kafka"

docker compose --project-name kafka --file $INFRA_DIR/cluster.yaml up -d