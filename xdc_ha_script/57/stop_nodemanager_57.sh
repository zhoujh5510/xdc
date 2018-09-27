#!/bin/bash

#stop nodemanager of 57
echo ">>>>>>>>stop nodemanager of 57 now "
su - root <<EOF
linux
sleep 2
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh stop nodemanager"
EOF
echo "stop nodemanager of 57 successfully "
