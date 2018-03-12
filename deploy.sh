#!/usr/bin/env bash

manager_machine_name=zk-node-1

if [ "$ENV" == "dev" ] ; then
    manager_machine_name=kafka-node-1
fi

function copy_compose_file {
    echo "======> copying compose file to manager node ..."
    docker-machine scp docker-compose.dev.yml $manager_machine_name:/
}

copy_compose_file

docker-machine ssh $manager_machine_name \
sudo docker stack deploy \
--compose-file /docker-compose.dev.yml \
--with-registry-auth \
kafka-cluster