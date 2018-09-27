drop table if exists TRAFODION.XDC_TEST.xdc3;
create table TRAFODION.XDC_TEST.xdc3(id int,name varchar(20),salary numeric(6,1),check(salary>500)) attribute synchronous replication;
