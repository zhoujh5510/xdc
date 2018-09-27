#!/bin/bash

#stop the hbase of 10.10.23.57
echo "begin to stop hbase of 10.10.23.57 now !!!!"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.57:8080/api/v1/clusters/ambari/services/HBASE
