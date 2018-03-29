#!/usr/bin/env bash

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

docker-machine ssh confluent mkdir -p /tmp/control-center/data

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
-e CONTROL_CENTER_CONNECT_CLUSTER="http://kafkaconnect:28082" \
--constraint="engine.labels.node.type==confluent" \
confluentinc/cp-enterprise-control-center:4.0.0 &

wait