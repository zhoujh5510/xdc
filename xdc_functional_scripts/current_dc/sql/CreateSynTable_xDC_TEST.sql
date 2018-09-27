drop table if exists TRAFODION.XDC_TEST."XDC_TEST";
create table TRAFODION.XDC_TEST."XDC_TEST"(id int not null primary key,name varchar(20),salary numeric(6,1)) attribute synchronous replication;
