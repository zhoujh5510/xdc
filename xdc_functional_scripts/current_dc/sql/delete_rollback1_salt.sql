set schema xdc_test;
log /opt/trafodion/xdc_automatic/logs_salt/delete_rollback_peer.log clear, CMDTEXT OFF
select * from xdc1;
log off
exit
