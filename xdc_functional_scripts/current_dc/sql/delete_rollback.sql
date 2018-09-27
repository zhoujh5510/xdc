set schema xdc_test;
begin work;
delete from TRAFODION.XDC_TEST.XDC1 where id=1;
delete from TRAFODION.XDC_TEST.XDC1 where id=2;
delete from TRAFODION.XDC_TEST.XDC1 where id=3;
delete from TRAFODION.XDC_TEST.XDC1 where id=4;
delete from TRAFODION.XDC_TEST.XDC1 where id=5;
delete from TRAFODION.XDC_TEST.XDC1 where id=6;
delete from TRAFODION.XDC_TEST.XDC1 where id=7;
delete from TRAFODION.XDC_TEST.XDC1 where id=8;
delete from TRAFODION.XDC_TEST.XDC1 where id=9;
delete from TRAFODION.XDC_TEST.XDC1 where id=10;
delete from TRAFODION.XDC_TEST.XDC1 where id=11;
delete from TRAFODION.XDC_TEST.XDC1 where id=12;
delete from TRAFODION.XDC_TEST.XDC1 where id=13;
delete from TRAFODION.XDC_TEST.XDC1 where id=14;
delete from TRAFODION.XDC_TEST.XDC1 where id=15;
delete from TRAFODION.XDC_TEST.XDC1 where id=16;
delete from TRAFODION.XDC_TEST.XDC1 where id=17;
delete from TRAFODION.XDC_TEST.XDC1 where id=18;
delete from TRAFODION.XDC_TEST.XDC1 where id=19;
delete from TRAFODION.XDC_TEST.XDC1 where id=20;
delete from TRAFODION.XDC_TEST.XDC1 where id=21;
delete from TRAFODION.XDC_TEST.XDC1 where id=22;
delete from TRAFODION.XDC_TEST.XDC1 where id=23;
delete from TRAFODION.XDC_TEST.XDC1 where id=24;
delete from TRAFODION.XDC_TEST.XDC1 where id=25;
delete from TRAFODION.XDC_TEST.XDC1 where id=26;
delete from TRAFODION.XDC_TEST.XDC1 where id=27;
delete from TRAFODION.XDC_TEST.XDC1 where id=28;
delete from TRAFODION.XDC_TEST.XDC1 where id=29;
log /opt/trafodion/xdc_automatic/logs/delete_rollback.log clear, CMDTEXT OFF
select * from xdc1;
log off
exit
