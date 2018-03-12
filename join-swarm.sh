#!/usr/bin/env bash
worker_machine=$1
manager_machine_name=zk-node-1

if [ "$ENV" == "dev" ] ; then
    manager_machine_name=kafka-node-1
fi

function get_ip {
    echo $(docker-machine ip $manager_machine_name)
}

function get_worker_token {
    # gets swarm manager token for a worker node
    echo $(docker-machine ssh $manager_machine_name sudo docker swarm join-token worker -q)
}

docker-machine ssh $worker_machine \
sudo docker swarm join \
    --token $(get_worker_token) \
    $(get_ip $manager_machine_name):2377
