#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC_FK values(1,'llll',123.4);" > /opt/trafodion/xdc_automatic/sql/insert_fk.sql
for((i=2;i<=300;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC_FK values(${i},'llll',123.4);" >> /opt/trafodion/xdc_automatic/sql/insert_fk.sql
done

