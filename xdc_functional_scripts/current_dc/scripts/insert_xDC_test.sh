#!/bin/bash


echo "insert into TRAFODION.XDC_TEST."XDC_TEST" values(1,'llll',123.4);" > /opt/trafodion/xdc_automatic/sql/insert_XDC_TEST.sql
for((i=2;i<=100;i++));
do
echo "insert into TRAFODION.XDC_TEST."XDC_TEST" values(${i},'llll',123.4);" >> /opt/trafodion/xdc_automatic/sql/insert_XDC_TEST.sql
done
