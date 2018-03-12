#!/usr/bin/env bash
# ami="ami-4f80b52a"
# ami="ami-6a5f6a0f"

# docker-machine create \
# --engine-label "node.type=$1" \
# --driver amazonec2 \
# --amazonec2-ami $ami \
# --amazonec2-vpc-id vpc-663eb80e \
# --amazonec2-subnet-id subnet-757e4b38 \
# --amazonec2-security-group kafka-cluster-dev \
# --amazonec2-instance-type t2.large \
# --amazonec2-region us-east-2 \
# --amazonec2-zone c \
# $1

docker-machine create \
--engine-label "node.type=$1" \
--driver digitalocean \
--digitalocean-image ubuntu-17-10-x64 \
--digitalocean-size 4gb \
--digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN \
$1