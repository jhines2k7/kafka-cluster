#!/usr/bin/env bash

node_type=$1
node_name=$node_type

if [ "$PROVIDER" == "aws" ] ; then
    instance_type=t2.large
    ami="ami-4f80b52a"
    # ami="ami-6a5f6a0f"

    docker-machine create \
    --engine-label "node.type=$node_type" \
    --driver amazonec2 \
    --amazonec2-ami $ami \
    --amazonec2-vpc-id vpc-663eb80e \
    --amazonec2-subnet-id subnet-757e4b38 \
    --amazonec2-security-group kafka-cluster-dev \
    --amazonec2-instance-type t2.large \
    --amazonec2-region us-east-2 \
    --amazonec2-zone c \
    $node_name
else
    size=4gb
    
    docker-machine create \
    --engine-label "node.type=$node_type" \
    --driver digitalocean \
    --digitalocean-image ubuntu-17-10-x64 \
    --digitalocean-size $size \
    --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN \
    $node_name
fi

#check to make sure docker was properly installed on node
echo "======> making sure docker is installed on $node_name"
docker-machine ssh $node_name docker