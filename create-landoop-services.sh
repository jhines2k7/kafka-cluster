#!/usr/bin/env bash

eval "$(docker-machine env landoop)"

docker service create \
--name kafkatopicsui \
--network kafkanet \
-p 8000:8000 \
-e KAFKA_REST_PROXY_URL=http://kafkarest:8082 \
-e PROXY=true \
--constraint "engine.labels.node.type==landoop" \
landoop/kafka-topics-ui &

docker service create \
--name schemaregistryui \
--network kafkanet \
-p 8000:8000 \
-e "SCHEMAREGISTRY_URL=http://schemaregistry:8081" \
--constraint "engine.labels.node.type==landoop" \
landoop/schema-registry-ui &

wait