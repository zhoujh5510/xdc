#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC values(1,'llll',123.4);" > /opt/trafodion/xdc_automatic/sql/insert_xdc.sql
for((i=2;i<=300;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC values(${i},'llll',123.4);" >> /opt/trafodion/xdc_automatic/sql/insert_xdc.sql
done

