#!/bin/bash

#start hbase master of cluster 57
echo ">>>>>>>>start hbase master of cluster 57 now !!!!!"
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start master"
EOF
echo ">>>>>>>>start hbase master successfully "
