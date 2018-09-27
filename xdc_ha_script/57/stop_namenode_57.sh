#!/bin/bash

#stop hdfs namenode of 57
echo ">>>>>>>>stop hdfs namenode of cluster 57 now "
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-namenode/../hadoop/sbin/hadoop-daemon.sh stop namenode"
EOF
echo "stop hdfs namenode of cluster 57 successfully "
