#!/bin/bash

#start the hbase of 10.10.23.31
echo "begin to start hbase of 10.10.23.31 now !!!!"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE
