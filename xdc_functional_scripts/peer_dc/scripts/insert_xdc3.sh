#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC3 values(1,'llll',123.4);" > /opt/trafodion/xdc_automatic/sql/insert_xdc3.sql
for((i=2;i<=10;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC3 values(${i},'llll',123.4);" >> /opt/trafodion/xdc_automatic/sql/insert_xdc3.sql
done

