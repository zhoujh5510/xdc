#!/bin/bash


#start datanode of 57
echo ">>>>>>>>start datanode of 57  now !!!!!"
su - root <<EOF
linux
sleep 2
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh start datanode"
EOF
echo "start datanode of 57 successfully "

echo ">>>>>>>>start datanode of 58  now !!!!!"
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.58
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh start datanode"
exit
EOF
echo "start datanode of 58 successfully "

echo ">>>>>>>>start datanode of 59  now !!!!!"
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.59
su -l hdfs -c "/usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh start datanode"
exit
EOF
echo "start datanode of 59 successfully "

echo ">>>>>>>>start All Data Node  successfully "
sleep 90

#region server will down as hdfs datanode down, restart region server
echo ">>>>>>>>start region server of 57 now !!!!"
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
EOF
echo "start region server of 57 successfully "

echo "start region server of 58 now !!!!"
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.58
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
exit
EOF
echo "start region server of 58 successfully "

echo "start region server of 59 now !!!!"
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.59
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
exit
EOF
echo "start region server of 59 successfully "

echo ">>>>>>>>all region server started successfully "


