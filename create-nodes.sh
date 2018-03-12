#!/usr/bin/env bash

failed_installs_file="./failed_installs.txt"
manager_machine_name=kafka-node-1

function init_swarm_manager {
    # initialize swarm mode and create a manager
    echo "======> Initializing swarm manager ..."
    
    local ip=$(docker-machine ip $manager_machine_name)

    echo "Swarm manager machine name: $manager_machine_name"

    docker-machine ssh $manager_machine_name sudo docker swarm init --advertise-addr $ip
}

function create_node_and_join_swarm {
    local node_name=$1

    bash create-node.sh $node_name

    result=$?

    if [ $result -eq 0 ] ; then
        bash set-ufw-rules.sh $node_name

        bash join-swarm.sh $node_name
    else
        echo "======> there was an error installing docker on $node_name"
    
        echo "$node_name" >> $failed_installs_file
    fi
}

if [ ! -e "$failed_installs_file" ] ; then
    touch "$failed_installs_file"
else
    > $failed_installs_file
fi

echo "ENV: $ENV"

if [ "$ENV" == "dev" ] ; then
    bash create-node.sh kafka-node-1

    result=$?

    if [ $result -ne 0 ]
    then
        echo "There was an error installing docker on the manager node. The script will now exit."
        
        echo "=====> Cleaning up..."

        bash ./remove-all-nodes.sh

        exit 1   
    fi

    init_swarm_manager

    for i in {2..3}; do
        create_node_and_join_swarm kafka-node-$i &
    done

    create_node_and_join_swarm webtools &

    wait
else
    manager_machine_name=zk-node-1

    bash create-node.sh zk-node-1

    result=$?

    if [ $result -ne 0 ]
    then
        echo "There was an error installing docker on the manager node. The script will now exit."
        
        echo "=====> Cleaning up..."

        bash ./remove-all-nodes.sh

        exit 1   
    fi

    init_swarm_manager

    for i in {2..3}; do
        create_node_and_join_swarm zk-node-$i &
    done

    for i in {1..3}; do
        create_node_and_join_swarm broker-node-$i &
    done

    wait
fi

echo "======> Finished creating cluster nodes."

echo "======> Creating overlay network."
docker-machine ssh $manager_machine_name docker network create -d overlay --attachable kafka-net

bash ./remove-nodes-with-failed-docker-installations.sh
