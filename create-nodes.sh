#!/usr/bin/env bash
manager_machine_name=kafka-node-1

function init_swarm_manager {
    # initialize swarm mode and create a manager
    echo "======> Initializing swarm manager ..."
    
    local ip=$(docker-machine ip $manager_machine_name)

    echo "Swarm manager machine name: $manager_machine_name"

    docker-machine ssh $manager_machine_name sudo docker swarm init --advertise-addr $ip
}

function get_ip {
    echo $(docker-machine ip $1)
}

function get_worker_token {
    # gets swarm manager token for a worker node
    echo $(docker-machine ssh $manager_machine_name sudo docker swarm join-token worker -q)
}

function join_swarm {
    local node_name=$1

    docker-machine ssh $node_name \
    sudo docker swarm join \
        --token $(get_worker_token) \
        $(get_ip $manager_machine_name):2377
}

function create_node_and_join_swarm {
    local node_name=$1

    bash create-node.sh $node_name

    join_swarm $node_name
}

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
fi

echo "======> Finished creating cluster nodes."

echo "======> Creating overlay network."
docker-machine ssh $manager_machine_name docker network create -d overlay --attachable kafka-net
