#!/bin/bash


#this script is used to config xdc between 10.10.23.31 and 10.10.23.57
echo "................begin to config xdc now ..................."
echo
echo "step 1 >>>>>>>>"
echo "1): make sure that change the file named hosts in /etc/, add peer DC`s ip and hostname !!"
echo
echo "2): make sure that change the peer file named hosts in /ect/, add current DC`s ip and hostname !!!"
echo
echo "3): make sure that in both DCs can login without password with user of trafodion, you can config it with script named noconfgenkey.py in current directory"

echo "step 2 >>>>>>>>"
echo "1): add_my_cluster_id 31 in current DC 10.10.23.31"
add_my_cluster_id 31
echo "2): add_my_cluster_id 57 in peer DC 10.10.23.57"
pdsh -w 10.10.23.57 "add_my_cluster_id 57"

echo "step 3 >>>>>>>>"
echo "1): add peer instance in current DC 10.10.23.31"
xdc_peer_add -i 57 -q esggy-qa-n007.esgyncn.local -p 2181
echo "2): add current instance in peer DC 10.10.23.57"
pdsh -w 10.10.23.57 "xdc_peer_add -i 31 -q esggy-qa-n001.esgyncn.local -p 2181"

echo "step 4 >>>>>>>>"
echo "1): execute xdc -pull and xdc -push in current DC"
xdc -pull
xdc -push

echo "step 5 >>>>>>>>"
echo "1): restart hbase of current DC 10.10.23.31"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE

sleep 30

curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.31:8080/api/v1/clusters/nn/services/HBASE

echo "2): restart hbase of peer DC 10.10.23.57"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' 10.10.23.57:8080/api/v1/clusters/ambari/services/HBASE

sleep 30

curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Start Service"},"Body":{"ServiceInfo":{"state":"STARTED"}}}' 10.10.23.57:8080/api/v1/clusters/ambari/services/HBASE

sleep 60

echo "step 6 >>>>>>>>"
echo "1): restart ESGYNDB of current DC 10.10.23.31"
sh ./stop_esgyndb.sh
sh ./start_esgyndb.sh
echo "2): restrat ESGYNDB of peer DC 10.10.23.57"
pdsh -w 10.10.23.57 "ckillall"
pdsh -w 10.10.23.57 "sqstart"
sleep 10

echo ".................xdc configuration complete now !!!!...................."
