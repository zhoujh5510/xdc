#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC1 values(1,'llll',123.4);" > /opt/trafodion/xdc_automatic/sql/insert.sql
for((i=2;i<=100;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC1 values(${i},'llll',123.4);" >> /opt/trafodion/xdc_automatic/sql/insert.sql
done

