#!/usr/bin/env bash

# for i in {1..3}; do
#     bash create-node.sh zk-node-$i &
# done

# for i in {1..3}; do
#     bash create-node.sh broker-node-$i &
# done

for i in {1..3}; do
    bash create-node.sh kafka-node-$i &
done

wait

bash create-node.sh webtools &
echo "======> Finished creating cluster nodes."