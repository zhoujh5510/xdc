et schema xdc_test;
drop table if exists TRAFODION.XDC_TEST.xdc2;
create table TRAFODION.XDC_TEST.xdc2(id int not null primary key,name varchar(20),salary numeric(6,1), id_f int, foreign key(id_f) references xdc_fk(id))attribute synchronous replication;
