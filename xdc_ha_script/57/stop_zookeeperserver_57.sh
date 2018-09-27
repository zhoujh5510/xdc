#!/bin/bash

#stop all zookeeper componenets
echo ">>>>>>>>begin to stop all zookeeper server of cluster 57 now "
echo
echo ">>>>>>>>begin to stop zookeeper server of 57 now " 2>&1 | tee -a ./stop_zookeeper_passive.log
#stop the zookeeper server of 57
su - root <<EOF
linux
sleep 2
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh stop"
EOF
echo ">>>>>>>>stop zookeeper server of 57 is successfully "

echo
echo ">>>>>>>>begin to stop zookeeper server of 58 now "
#stop the zookeeper server of 57
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.58
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh stop"
exit
EOF
echo ">>>>>>>>stop zookeeper server of 59 is successfully "

echo
echo ">>>>>>>>begin to stop zookeeper server of 59 now "
#stop the zookeeper server of 57
su - root <<EOF
linux
sleep 2
ssh -T 10.10.23.59
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh stop"
exit
EOF
echo ">>>>>>>>stop zookeeper server of 59 is successfully "
echo
echo ">>>>>>>>stop all zookeeper server is successfully "

