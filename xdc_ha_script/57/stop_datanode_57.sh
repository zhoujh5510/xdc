#!/bin/bash

echo ">>>>>>>>stop datanode of cluster 57 now "
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh stop datanode"
exit
EOF
echo "stop datanode of 57 successfully "

