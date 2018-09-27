set schema xdc_test;
log /opt/trafodion/xdc_automatic/logs/compare_peer_xdc_test.log clear, CMDTEXT OFF
select * from TRAFODION.SEABASE.XDC_TEST.xdc_test;
log off
exit
