#!/bin/bash

INFRA_DIR="infrastructure/elk"

docker compose --project-name elk --file $INFRA_DIR/cluster.yaml up -d