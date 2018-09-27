#!/bin/bash

#stop name node
echo "stop zookeeper now "
sh ./stop_zookeeper.sh


sleep 60
#start namenode as start HDFS
echo "start zookeeper now !!!!!"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/ZOOKEEPER
