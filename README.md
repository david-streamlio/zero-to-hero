# From Zero to Streaming Hero

Requirements
------------

- [Docker](https://www.docker.com/get-started) 4.24+


Ensure you have allocated enough resources to Docker. At least 16GB of RAM, and 8 cores.

Note: *On Macs with ARM chip, enabling Rosetta for amd64 emulation on Docker will make your containers boot faster.*


🏢 Streaming Platform Infrastructure
--------------------------------------

Before jumping into any of the scenarios, you must start the shared infrastructure for the underlying streaming platform. 
This includes Apache Flink, Apache Pulsar, Elasticsearch, Kibana, and MySQL


1️⃣ Start Pulsar
--

Apache Pulsar is an open-source, distributed messaging and streaming platform built for the cloud. It will serve as our
event streaming storage platform for this demo.

```bash
sh ./bin/start-pulsar.sh
```

2️⃣ Start Flink
--

Apache Flink is a framework and distributed processing engine for stateful computations over unbounded and bounded data 
streams. It will serve as our distributed streaming computation platform for this demo. You can start it using the following
command:

```bash
sh ./bin/start-flink.sh
```

Next, you must wait until the Flink containers are all running.....

```
docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                              NAMES
1c010948d856   flink:latest   "/docker-entrypoint.…"   6 seconds ago   Up 6 seconds   6123/tcp, 8081/tcp                 flink-taskmanager-2
bef31746866c   flink:latest   "/docker-entrypoint.…"   6 seconds ago   Up 6 seconds   6123/tcp, 8081/tcp                 flink-taskmanager-1
dca492aaa5ef   flink:latest   "/docker-entrypoint.…"   6 seconds ago   Up 6 seconds   6123/tcp, 0.0.0.0:8081->8081/tcp   flink-jobmanager-1
```

At this point, the Apache Flink Web UI is now available at http://localhost:8081

![Flink-UI.png](images%2FFlink-UI.png)

3️⃣ Start Elasticsearch and Kibana
--

Elasticsearch is the distributed search and analytics engine at the heart of the Elastic Stack, aka ELK. Logstash and Beats 
facilitate collecting, aggregating, and enriching your data and storing it in Elasticsearch. Kibana enables you to 
interactively explore, visualize, and share insights into your data and manage and monitor the stack. Elasticsearch is 
where the indexing, search, and analysis magic happens. 

It will serve as the data analytics and visualization platform of our streaming platform. You can start it using the 
following command:

```bash
sh ./bin/start-elk.sh
```

Next, you must wait until the ELK containers are all running.....

```
CONTAINER ID   IMAGE                                                     COMMAND                  CREATED              STATUS                        PORTS                                            NAMES
0a5951db62cb   docker.elastic.co/kibana/kibana-oss:7.9.0                 "/usr/local/bin/dumb…"   3 seconds ago        Up 2 seconds                  0.0.0.0:5601->5601/tcp                           elk-kibana-1
1c2fd35310bf   docker.elastic.co/elasticsearch/elasticsearch-oss:7.9.0   "/tini -- /usr/local…"   3 seconds ago        Up 2 seconds                  0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp   elk-elasticsearch-1
```

At this point, the Kibana UI should be available at http://localhost:5601 

![Elastic-UI.png](images%2FElastic-UI.png)

4️⃣ Start MySQL
--

MySQL is a relational database management system (RDBMS) developed by Oracle that is based on structured query language (SQL).
For this demo, it will serve as a traditional data warehouse that is queried to enrich our streaming data. You can start 
it using the following command:


```bash
sh ./bin/start-mysql.sh
```

5️⃣ Start the Flink SQL client
--

The Flink SQL Client aims to provide an easy way of writing, debugging, and submitting table programs to a Flink cluster
without a single line of Java or Scala code. The SQL client makes it possible to work with queries written in the SQL language
to manipulate streaming data. 

Users have two options for starting the SQL Client CLI, either by starting an embedded standalone process inside a shell
using the following command:

```bash
sh ./bin/start-sql-client.sh
```

Alternatively, you can exec directly into the sql-client-1 container using Docker Desktop, and executing the following
command to start the SQL client:

```bash
./bin/sql-client.sh embedded -l /opt/sql-client/lib
```

![Flink-SQL-UI.png](images%2FFlink-SQL-UI.png)


References
------------
- [Building an end-to-end Streaming Application](https://flink.apache.org/2020/07/28/flink-sql-demo-building-an-end-to-end-streaming-application/)
- [Flink SQL docker compose example](https://github.com/Aiven-Open/sql-cli-for-apache-flink-docker/blob/main/docker-compose.yml)
- [Flink Docker Reference](https://frameworks.readthedocs.io/en/latest/big-data/apache/flinkDocker.html)
- https://blog.rockthejvm.com/pulsar-flink/
- https://streamnative.io/blog/announcing-flink-pulsar-sql-connector
