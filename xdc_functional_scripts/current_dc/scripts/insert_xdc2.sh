#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC2 values(1,'llll',123.4,1);" > /opt/trafodion/xdc_automatic/sql/insert_xdc2.sql
for((i=2;i<=300;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC2 values(${i},'llll',123.4,${i});" >> /opt/trafodion/xdc_automatic/sql/insert_xdc2.sql
done

