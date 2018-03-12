#!/usr/bin/env bash

eval "$(docker-machine env zk-node-1)"

docker run --net=kafka-net --rm confluentinc/cp-zookeeper:4.0.0 bash -c "echo stat | nc zk1 22181 | grep Mode"
docker run --net=kafka-net --rm confluentinc/cp-zookeeper:4.0.0 bash -c "echo stat | nc zk2 32181 | grep Mode"
docker run --net=kafka-net --rm confluentinc/cp-zookeeper:4.0.0 bash -c "echo stat | nc zk3 42181 | grep Mode"
