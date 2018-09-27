drop table if exists TRAFODION.XDC_TEST.xdc3;
create table TRAFODION.XDC_TEST.xdc3(id int not null primary key,name varchar(20),salary numeric(6,1),check(salary>500)) salt using 4 partitions attribute synchronous replication;
