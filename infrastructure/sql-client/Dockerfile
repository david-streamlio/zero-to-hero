FROM flink:latest

# Copy executables
COPY sql-client/bin/* /opt/sql-client/

# Create CLI lib folder
RUN mkdir -p /opt/sql-client/lib

ARG m2_repo="https://repo.maven.apache.org/maven2"

# Download connector libraries
RUN wget -P /opt/sql-client/lib/ ${m2_repo}/org/apache/flink/flink-sql-connector-elasticsearch7/3.0.1-1.17/flink-sql-connector-elasticsearch7-3.0.1-1.17.jar; \
    wget -P /opt/sql-client/lib/ ${m2_repo}/org/apache/flink/flink-sql-connector-kafka/1.17.1/flink-sql-connector-kafka-1.17.1.jar; \
    wget -P /opt/sql-client/lib/ ${m2_repo}/org/apache/flink/flink-connector-jdbc/3.1.1-1.17/flink-connector-jdbc-3.1.1-1.17.jar; \
    wget -P /opt/sql-client/lib/ ${m2_repo}/org/apache/flink/flink-json/1.17.1/flink-json-1.17.1.jar; \
    wget -P /opt/sql-client/lib/ https://jdbc.postgresql.org/download/postgresql-42.5.4.jar; \
    wget -P /opt/sql-client/lib/ https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar; \
    wget -P /opt/sql-client/lib/ ${m2_repo}/org/apache/flink/flink-sql-avro-confluent-registry/1.17.1/flink-sql-avro-confluent-registry-1.17.1.jar; \
    wget -P /opt/sql-client/lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-pulsar/4.1.0-1.18/flink-connector-pulsar-4.1.0-1.18.jar; \
    wget -P /opt/sql-client/lib/ https://github.com/knaufk/flink-faker/releases/download/v0.5.3/flink-faker-0.5.3.jar;