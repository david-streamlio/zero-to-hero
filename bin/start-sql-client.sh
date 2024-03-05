#!/bin/bash

docker-compose --project-name flink exec sql-client ./bin/sql-client.sh embedded -l /opt/sql-client/lib