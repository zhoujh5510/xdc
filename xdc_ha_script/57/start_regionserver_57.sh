#!/bin/bash

#start region server of passive DC 57
echo ">>>>>>>>start regionserver of passive DC 57 now !!!!!"
su - root <<EOF
linux
sleep 2
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
EOF
echo "start region server of passive DC 57 successfully"
