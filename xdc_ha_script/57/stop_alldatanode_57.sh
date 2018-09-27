#!/bin/bash

#stop datanode of 57
echo ">>>>>>>>stop datanode of 57"
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh stop datanode"
EOF
echo "stop datanode of 57 successfully "

#stop datanode of 58
echo ">>>>>>>>begin to stop datanode of 58 now "
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.58
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh stop datanode"
exit
EOF
echo "stop datanode of 58 successfully "

#stop datanode of 59
echo ">>>>>>>>begin to stop datanode of 59 now "
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.59
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh stop datanode"
exit
EOF
echo "stop datanode of 59 successfully "

