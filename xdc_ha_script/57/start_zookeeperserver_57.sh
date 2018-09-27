#!/bin/bash

#start all zookeeper components
echo ">>>>>>>>start all zookeeper server now !!!!!"
echo ">>>>>>>>begin to start zookeeper server of 57 now "
#start the zookeeper server of 57
su - root <<EOF
linux
sleep 2
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh start"
EOF
echo ">>>>>>>>start zookeeper server of 57 is successfully "

echo
echo ">>>>>>>>begin to start zookeeper server of 58 now "
#start the zookeeper server of 57
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.58
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh start"
exit
EOF
echo ">>>>>>>>start zookeeper server of 59 is successfully "

echo
echo ">>>>>>>>begin to start zookeeper server of 59 now "
#start the zookeeper server of 57
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.59
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh start"
exit
EOF
echo ">>>>>>>>start zookeeper server of 59 is successfully "
echo

echo ">>>>>>>>start all zookeeper server successfully !!!!"
