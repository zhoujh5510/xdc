#!/bin/bash

#get zookeeper leader
for i in 10.10.23.31 10.10.23.32;
do
        echo status | nc $i 2181 > ./get_lead.log
        rt=$(grep -c "leader" ./get_lead.log)
        if [ $rt -eq 1 ];then
                echo "The leader of Zookeeper Server is in: $i"
                break;
        fi
done


#stop the zookeeper server of lead
su - root <<EOF
linux
ssh -T $i
hostname -f
#su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh stop"
exit
EOF

#start the zookeeper server of lead
su - root <<EOF
linux
ssh -T $i
su - zookeeper -c "export ZOOCFGDIR=/usr/hdp/current/zookeeper-server/conf; export ZOOCFG=zoo.cfg; source /usr/hdp/current/zookeeper-server/conf/zookeeper-env.sh ; /usr/hdp/current/zookeeper-server/bin/zkServer.sh start"
exit
EOF
