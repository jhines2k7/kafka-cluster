#!/usr/bin/env bash

docker-machine ssh confluent mkdir -p /tmp/quickstart/file
docker-machine ssh confluent mkdir -p /tmp/control-center/data

node_name=zk-node-1

if [ "$ENV" == "dev" ] ; then
    node_name=kafka-node-1
fi

eval "$(docker-machine env $node_name)"

docker service create \
--name schemaregistry \
--network kafkanet \
-e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL="zk1:22181,zk2:32181,zk3:42181" \
-e SCHEMA_REGISTRY_HOST_NAME="schemaregistry" \
-e SCHEMA_REGISTRY_LISTENERS="http://0.0.0.0:8081" \
--constraint="engine.labels.node.type==confluent" \
confluentinc/cp-schema-registry:4.0.0 &

docker service create \
--name kafkarest \
--network kafkanet \
-e KAFKA_REST_ZOOKEEPER_CONNECT="zk1:22181,zk2:32181,zk3:42181" \
-e KAFKA_REST_LISTENERS="http://0.0.0.0:8082" \
-e KAFKA_REST_SCHEMA_REGISTRY_URL="http://schemaregistry:8081" \
-e KAFKA_REST_HOST_NAME="kafkarest" \
--constraint="engine.labels.node.type==confluent" \
confluentinc/cp-kafka-rest:4.0.0 &

docker service create \
--name=kafkaconnect \
--network=kafkanet \
-e CONNECT_PRODUCER_INTERCEPTOR_CLASSES=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor \
-e CONNECT_CONSUMER_INTERCEPTOR_CLASSES=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor \
-e CONNECT_BOOTSTRAP_SERVERS=kafka1:29092,kafka2:39092,kafka3:49092 \
-e CONNECT_REST_HOST_NAME="kafkaconnect" \
-e CONNECT_REST_PORT=8083 \
-e CONNECT_GROUP_ID="kafkaconnect" \
-e CONNECT_CONFIG_STORAGE_TOPIC="connect-config" \
-e CONNECT_OFFSET_STORAGE_TOPIC="connect-offsets" \
-e CONNECT_STATUS_STORAGE_TOPIC="connect-status" \
-e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3 \
-e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3 \
-e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3 \
-e CONNECT_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
-e CONNECT_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
-e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
-e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
-e CONNECT_REST_ADVERTISED_HOST_NAME="kafkaconnect" \
-e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG \
-e CONNECT_LOG4J_LOGGERS=org.reflections=ERROR \
-e CONNECT_PLUGIN_PATH=/usr/share/java \
--mount type=bind,source=/tmp/quickstart/file,destination=/tmp/quickstart \
--constraint "engine.labels.node.type==confluent" \
confluentinc/cp-kafka-connect:4.0.0 &

docker service create \
--name controlcenter \
--network kafkanet \
-p 9021:9021 \
--mount type=bind,source=/tmp/control-center/data,destination=/var/lib/confluent-control-center \
-e CONTROL_CENTER_ZOOKEEPER_CONNECT="zk1:22181,zk2:32181,zk3:42181" \
-e CONTROL_CENTER_BOOTSTRAP_SERVERS="kafka1:29092,kafka2:39092,kafka3:49092" \
-e CONTROL_CENTER_REPLICATION_FACTOR=3 \
-e CONTROL_CENTER_MONITORING_INTERCEPTOR_TOPIC_PARTITIONS=5 \
-e CONTROL_CENTER_INTERNAL_TOPICS_PARTITIONS=5 \
-e CONTROL_CENTER_STREAMS_NUM_STREAM_THREADS=2 \
-e CONTROL_CENTER_CONNECT_CLUSTER="http://kafkaconnect:8083" \
--constraint="engine.labels.node.type==confluent" \
confluentinc/cp-enterprise-control-center:4.0.0 &

wait