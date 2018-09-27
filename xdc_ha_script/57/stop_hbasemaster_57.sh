#!/bin/bash

#stop hbase master of cluster 57
echo ">>>>>>>>stop hbase master of cluster 57 now"
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh stop master"
EOF
echo "stop hbase master of cluster 57 successfully "
