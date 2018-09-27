set schema xdc_test;
begin work;
insert into TRAFODION.XDC_TEST.XDC1 values(1,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(2,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(3,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(4,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(5,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(6,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(7,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(8,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(9,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(10,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(11,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(12,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(13,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(14,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(15,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(16,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(17,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(18,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(19,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(20,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(21,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(22,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(23,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(24,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(25,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(26,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(27,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(28,'llll',123.4);
insert into TRAFODION.XDC_TEST.XDC1 values(29,'llll',123.4);
log /opt/trafodion/xdc_automatic/logs/insert_rollback.log clear, CMDTEXT OFF
select * from xdc1;
log off
exit
