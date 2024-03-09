# From Zero to Streaming Hero

Requirements
------------

- [Docker](https://www.docker.com/get-started) 4.11+
- [Java](https://openjdk.org/install/) 17+
- [Maven](https://maven.apache.org/download.cgi) 3.8.6+


Ensure you have allocated enough memory to Docker: at least 8Gb.

On Macs with ARM chip, enabling Rosetta for amd64 emulation on Docker will make your containers boot faster.



🏢 Streaming Platform Infrastructure
--------------------------------------

Before jumping into any of the scenarios, you must start the shared infrastructure for the underlying streaming platform. 
This includes Apache Flink and Apache Pulsar


1️⃣ Start Pulsar


2️⃣ Start Flink

```bash
sh ./bin/start-flink.sh
```


👀 You must wait until the Flink containers are all running

```
docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                              NAMES
1c010948d856   flink:latest   "/docker-entrypoint.…"   6 seconds ago   Up 6 seconds   6123/tcp, 8081/tcp                 flink-taskmanager-2
bef31746866c   flink:latest   "/docker-entrypoint.…"   6 seconds ago   Up 6 seconds   6123/tcp, 8081/tcp                 flink-taskmanager-1
dca492aaa5ef   flink:latest   "/docker-entrypoint.…"   6 seconds ago   Up 6 seconds   6123/tcp, 0.0.0.0:8081->8081/tcp   flink-jobmanager-1
```

At this point, the Apache Flink Web UI is now available at localhost:8081

![Flink-UI.png](images%2FFlink-UI.png)

3 Start the Flink SQL client

```bash
sh ./bin/start-sql-client.sh
```

References
------------
- [Building an end-to-end Streaming Application](https://flink.apache.org/2020/07/28/flink-sql-demo-building-an-end-to-end-streaming-application/)
- [Flink SQL docker compose example](https://github.com/Aiven-Open/sql-cli-for-apache-flink-docker/blob/main/docker-compose.yml)
- [Flink Docker Reference](https://frameworks.readthedocs.io/en/latest/big-data/apache/flinkDocker.html)
- https://blog.rockthejvm.com/pulsar-flink/
- https://streamnative.io/blog/announcing-flink-pulsar-sql-connector
