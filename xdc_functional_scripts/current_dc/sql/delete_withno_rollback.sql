set schema xdc_test;
begin work;
delete with no rollback from TRAFODION.XDC_TEST.xdc1 where id < 100;
log /opt/trafodion/xdc_automatic/logs/delete_withno_rollback.log clear, CMDTEXT OFF
select * from xdc1;
log off
exit
