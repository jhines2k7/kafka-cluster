#!/usr/bin/env bash

node_name=zk-node-1

if [ "$ENV" == "dev" ] ; then
    node_name=kafka-node-1
fi

eval "$(docker-machine env $node_name)"

docker service create \
--name kafkatopicsui \
--network kafkanet \
-p 8000:8000 \
-e "KAFKA_REST_PROXY_URL=http://kafkarest:8082" \
-e "PROXY=true" \
--constraint="engine.labels.node.type==confluent" \
landoop/kafka-topics-ui &

docker service create \
--name schemaregistryui \
--network kafkanet \
-p 8100:8000 \
-e "SCHEMAREGISTRY_URL=http://schemaregistry:8081" \
-e "PROXY=true" \
--constraint="engine.labels.node.type==confluent" \
landoop/schema-registry-ui &

# docker service create \
# --name kafkaconnectui \
# --network kafkanet \
# -p 8200:8000 \
# -e "CONNECT_URL=http://104.131.121.218:8083" \
# -e "PROXY=false" \
# --constraint="engine.labels.node.type==confluent" \
# landoop/kafka-connect-ui &

wait