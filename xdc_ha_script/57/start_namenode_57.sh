#!/bin/bash

#start hdfs namenode of 57
echo ">>>>>>>>>start hdfs namenode of cluster 57 now !!!!!"
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-namenode/../hadoop/sbin/hadoop-daemon.sh start namenode"
EOF
echo "start hdfs namenode of 57 successfully "
