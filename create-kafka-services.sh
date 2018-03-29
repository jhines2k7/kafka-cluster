#!/usr/bin/env bash

node_name=zk-node-1

if [ "$ENV" == "dev" ] ; then
    node_name=kafka-node-1
fi

node_type_1=broker-node-1
node_type_2=broker-node-2
node_type_3=broker-node-3

if [ "$ENV" == "dev" ] ; then
    node_type_1=kafka-node-1
    node_type_2=kafka-node-2
    node_type_3=kafka-node-3
fi

eval "$(docker-machine env $node_name)"

docker service create \
--name kafka1 \
--network kafkanet \
-e KAFKA_ZOOKEEPER_CONNECT="zk1:22181,zk2:32181,zk3:42181" \
-e KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://kafka1:29092" \
--constraint="engine.labels.node.type==$node_type_1" \
confluentinc/cp-kafka:4.0.0 &

docker service create \
--name kafka2 \
--network kafkanet \
-e KAFKA_ZOOKEEPER_CONNECT="zk1:22181,zk2:32181,zk3:42181" \
-e KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://kafka2:39092" \
--constraint="engine.labels.node.type==$node_type_2" \
confluentinc/cp-kafka:4.0.0 &

docker service create \
--name kafka3 \
--network kafkanet \
-e KAFKA_ZOOKEEPER_CONNECT="zk1:22181,zk2:32181,zk3:42181" \
-e KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://kafka3:49092" \
--constraint="engine.labels.node.type==$node_type_3" \
confluentinc/cp-kafka:4.0.0 &

wait