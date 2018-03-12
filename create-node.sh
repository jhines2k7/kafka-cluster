#!/usr/bin/env bash

failed_installs_file="./failed_installs.txt"

node_type=$1
node_name=$node_type

if [ "$PROVIDER" == "aws" ] ; then
    instance_type=t2.large
    ami="ami-4f80b52a"
    # ami="ami-6a5f6a0f"

    if [ "$node_type" == "webtools" ] ; then
        instance_type=t2.small
    fi

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

    if [ "$node_type" == "webtools" ] ; then
        size=2gb
    fi

    docker-machine create \
    --engine-label "node.type=$node_type" \
    --driver digitalocean \
    --digitalocean-image ubuntu-17-10-x64 \
    --digitalocean-size $size \
    --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN \
    $node_name
fi

if [ ! -e "$failed_installs_file" ] ; then
    touch "$failed_installs_file"
fi

#check to make sure docker was properly installed on node
echo "======> making sure docker is installed on $node_name"
docker-machine ssh $node_name docker

if [ $? -ne 0 ] ; then
    echo "======> there was an error installing docker on $node_name"
    
    echo "$node_name" >> $failed_installs_file

    return 1
fi