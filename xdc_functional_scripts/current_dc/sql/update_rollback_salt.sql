set schema xdc_test;
begin work;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 1;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 2;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 3;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 4;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 5;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 6;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 7;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 8;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 9;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 10;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 11;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 12;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 13;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 14;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 15;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 16;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 17;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 18;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 19;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 20;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 21;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 22;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 23;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 24;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 25;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 26;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 27;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 28;
update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 29;
log /opt/trafodion/xdc_automatic/logs_salt/update_rollback.log clear, CMDTEXT OFF
select * from xdc1;
log off
exit
