#!/bin/bash

#stop nodemanager of 57
echo ">>>>>>>>stop nodemanager of 57"
su - root <<EOF
linux
sleep 2
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh stop nodemanager"
EOF
echo "stop nodemanager of 31 successfully "

#stop nodemanager of 58
echo ">>>>>>>>begin to stop nodemanager of 58 now "
su - root <<EOF
linux
ssh -T 10.10.23.58
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh stop nodemanager"
exit
EOF
echo "stop nodemanager of 58 successfully "

#stop nodemanager of 59
echo ">>>>>>>>begin to stop nodemanager of 59 now "
su - root <<EOF
linux
ssh -T 10.10.23.59
su -l yarn -c "/usr/hdp/current/hadoop-yarn-nodemanager/sbin/yarn-daemon.sh stop nodemanager"
exit
EOF
echo "stop nodemanager of 59 successfully "
