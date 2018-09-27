set schema xdc_test;
begin work;
load into TRAFODION.XDC_TEST.xdc1 select * from TRAFODION.XDC_TEST.xdc;
log /opt/trafodion/xdc_automatic/logs_salt/load_rollback.log clear, CMDTEXT OFF
select * from xdc1;
log off
exit
