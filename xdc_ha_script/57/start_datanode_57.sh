#!/bin/bash

#start datanode of cluster 57
echo ">>>>>>>>start datanode of 57 now "
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.57
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh start datanode"
exit
EOF
echo "start datanode of cluster 57 successfully "
echo ">>>>>>>>start datanode successfully"

#region server will down as hdfs datanode down, restart region server
echo ">>>>>>>>start region server of 57 now !!!!"
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
EOF
echo "start region server of 57 successfully "
