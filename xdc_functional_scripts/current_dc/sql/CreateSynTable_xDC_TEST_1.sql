drop table if exists TRAFODION.XDC_TEST."xDC_test";
create table TRAFODION.XDC_TEST."xDC_test"(id int not null primary key,name varchar(20),salary numeric(6,1)) attribute synchronous replication;
