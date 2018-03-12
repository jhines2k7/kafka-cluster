#!/usr/bin/env bash

node_type_1=zk-node-1
node_type_2=zk-node-2
node_type_3=zk-node-3

if [ "$ENV" == "dev" ] ; then
    node_type_1=kafka-node-1
    node_type_2=kafka-node-2
    node_type_3=kafka-node-3
fi

docker service create \
--network kafka-net \
--name zk1 \
-e ZOOKEEPER_SERVER_ID=1 \
-e ZOOKEEPER_CLIENT_PORT=22181 \
-e ZOOKEEPER_TICK_TIME=2000 \
-e ZOOKEEPER_INIT_LIMIT=5 \
-e ZOOKEEPER_SYNC_LIMIT=2 \
-e ZOOKEEPER_SERVERS="0.0.0.0:22888:23888;zk2:32888:33888;zk3:42888:43888" \
--constraint "engine.labels.node.type==$node_type_1" \
confluentinc/cp-zookeeper:4.0.0

docker service create \
--network kafka-net \
--name zk2 \
-e ZOOKEEPER_SERVER_ID=2 \
-e ZOOKEEPER_CLIENT_PORT=32181 \
-e ZOOKEEPER_TICK_TIME=2000 \
-e ZOOKEEPER_INIT_LIMIT=5 \
-e ZOOKEEPER_SYNC_LIMIT=2 \
-e ZOOKEEPER_SERVERS="zk1:22888:23888;0.0.0.0:32888:33888;zk3:42888:43888" \
--constraint "engine.labels.node.type==$node_type_2" \
confluentinc/cp-zookeeper:4.0.0

docker service create \
--network kafka-net \
--name zk3 \
-e ZOOKEEPER_SERVER_ID=3 \
-e ZOOKEEPER_CLIENT_PORT=42181 \
-e ZOOKEEPER_TICK_TIME=2000 \
-e ZOOKEEPER_INIT_LIMIT=5 \
-e ZOOKEEPER_SYNC_LIMIT=2 \
-e ZOOKEEPER_SERVERS="zk1:22888:23888;zk2:32888:33888;0.0.0.0:42888:43888" \
--constraint "engine.labels.node.type==$node_type_3" \
confluentinc/cp-zookeeper:4.0.0