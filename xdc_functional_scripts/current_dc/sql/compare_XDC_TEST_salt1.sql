set schema xdc_test;
log /opt/trafodion/xdc_automatic/logs_salt/compare_current_xdc_test.log clear, CMDTEXT OFF
select * from "xDC_test";
log off
exit
