#!/usr/bin/env bash

#remove all nodes
for machine in $(docker-machine ls --format "{{.Name}}" | grep 'broker\|zk-node\|kafka-node\|confluence');
    do docker-machine rm -f $machine;
done