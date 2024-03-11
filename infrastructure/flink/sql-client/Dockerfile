FROM flink:latest

# Create CLI lib folder
RUN mkdir -p /opt/sql-client/lib

ARG MAVEN_REPO="https://repo1.maven.org/maven2"
ARG APACHE_REPO="https://repo.maven.apache.org/maven2"

# Download connector libraries
RUN wget -P /opt/sql-client/lib/ ${APACHE_REPO}/org/apache/flink/flink-sql-connector-elasticsearch7/3.0.1-1.17/flink-sql-connector-elasticsearch7-3.0.1-1.17.jar; \
    wget -P /opt/sql-client/lib/ ${APACHE_REPO}/org/apache/flink/flink-sql-connector-kafka/1.17.1/flink-sql-connector-kafka-1.17.1.jar; \
    wget -P /opt/sql-client/lib/ ${APACHE_REPO}/org/apache/flink/flink-connector-jdbc/3.1.1-1.17/flink-connector-jdbc-3.1.1-1.17.jar; \
    wget -P /opt/sql-client/lib/ ${APACHE_REPO}/org/apache/flink/flink-json/1.18.1/flink-json-1.18.1.jar; \
    wget -P /opt/sql-client/lib/ https://jdbc.postgresql.org/download/postgresql-42.5.4.jar; \
    wget -P /opt/sql-client/lib/ ${MAVEN_REPO}/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar; \
    wget -P /opt/sql-client/lib/ ${APACHE_REPO}/org/apache/flink/flink-sql-avro-confluent-registry/1.17.1/flink-sql-avro-confluent-registry-1.17.1.jar; \
    wget -P /opt/sql-client/lib/ ${MAVEN_REPO}/io/streamnative/connectors/flink-connector-pulsar/4.1.1/flink-connector-pulsar-4.1.1.jar; \
    wget -P /opt/sql-client/lib/ ${MAVEN_REPO}/org/apache/pulsar/pulsar-client-api/3.0.0/pulsar-client-api-3.0.0.jar; \
    wget -P /opt/sql-client/lib/ ${MAVEN_REPO}/org/apache/pulsar/pulsar-client-all/3.0.0/pulsar-client-all-3.0.0.jar; \
    wget -P /opt/sql-client/lib/ ${MAVEN_REPO}/org/apache/pulsar/pulsar-client-admin-api/3.0.0/pulsar-client-admin-api-3.0.0.jar; \
    wget -P /opt/sql-client/lib/ ${MAVEN_REPO}/com/fasterxml/jackson/core/jackson-annotations/2.15.4/jackson-annotations-2.15.4.jar; \
    wget -P /opt/sql-client/lib/ https://github.com/knaufk/flink-faker/releases/download/v0.5.3/flink-faker-0.5.3.jar;