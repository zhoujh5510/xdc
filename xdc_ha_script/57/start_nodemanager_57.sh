#!/bin/bash

#start nodemanager of 57
echo ">>>>>>>>start nodemanager of 57 now "
su - root <<EOF
linux
sleep 2
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh start nodemanager"
EOF
echo "start nodemanager of 57 successfully " 
echo ">>>>>>>>start nodemanager successfully" 
