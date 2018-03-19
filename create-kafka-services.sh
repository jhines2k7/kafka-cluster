#!/usr/bin/env bash

node_type_1=broker-node-1
node_type_2=broker-node-2
node_type_3=broker-node-3

if [ "$ENV" == "dev" ] ; then
    node_type_1=kafka-node-1
    node_type_2=kafka-node-2
    node_type_3=kafka-node-3
fi

docker service create \
--network=kafkanet \
--name=kafka1 \
-e KAFKA_ZOOKEEPER_CONNECT=zk1:22181,zk2:32181,zk3:42181 \
-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka1:29092 \
--constraint "engine.labels.node.type==$node_type_1" \
confluentinc/cp-kafka:4.0.0 &

docker service create \
--network=kafkanet \
--name=kafka2 \
-e KAFKA_ZOOKEEPER_CONNECT=zk1:22181,zk2:32181,zk3:42181 \
-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka2:39092 \
--constraint "engine.labels.node.type==$node_type_2" \
confluentinc/cp-kafka:4.0.0 &

docker service create \
--network=kafkanet \
--name=kafka3 \
-e KAFKA_ZOOKEEPER_CONNECT=zk1:22181,zk2:32181,zk3:42181 \
-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka3:49092 \
--constraint "engine.labels.node.type==$node_type_3" \
confluentinc/cp-kafka:4.0.0 &

wait