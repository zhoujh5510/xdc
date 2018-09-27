#!/bin/bash

echo "stop hbase"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.57:8080/api/v1/clusters/ambari/services/HBASE

sleep 100

#start hbase master of cluster 57
echo ">>>>>>>>start hbase master of cluster 57 now !!!!!"
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start master"
EOF
echo ">>>>>>>>start hbase master successfully "
