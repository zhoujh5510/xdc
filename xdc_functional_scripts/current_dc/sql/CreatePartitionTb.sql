drop table if exists TRAFODION.XDC_TEST.xdc4;
create table TRAFODION.XDC_TEST.xdc4(id int not null primary key,name varchar(20),salary numeric(6,1)) salt using 4 partitions attribute synchronous replication;
