#!/bin/bash

INFRA_DIR="infrastructure/flink"

docker compose --project-name flink --file $INFRA_DIR/cluster.yaml up -d