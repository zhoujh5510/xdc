#!/bin/bash

#start nodemanager of cluster 57
echo ">>>>>>>>start nodemanager of 57  now !!!!!"
su - root <<EOF
linux
sleep 2
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh start nodemanager"
EOF
echo "start nodemanager of 57 successfully "
echo
echo ">>>>>>>>start nodemanager of 58  now !!!!!"
su - root <<EOF
linux
ssh -T 10.10.23.58
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh start nodemanager"
exit
EOF
echo "start nodemanager of 58 successfully "
echo ">>>>>>>>start nodemanager of 59  now !!!!!"
su - root <<EOF
linux
ssh -T 10.10.23.59
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh start nodemanager"
exit
EOF
echo "start nodemanager of 59 successfully "

echo ">>>>>>>>start All  Node Manager  successfully "
