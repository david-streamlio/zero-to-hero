#!/bin/bash

INFRA_DIR="infrastructure"

docker compose --project-name flink --file $INFRA_DIR/flink.yaml up -d