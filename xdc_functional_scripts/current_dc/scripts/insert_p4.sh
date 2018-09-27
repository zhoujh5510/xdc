#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC4 values(1,'llll',123.4);" > /opt/trafodion/xdc_automatic/sql/insert_p4.sql
for((i=2;i<=300;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC4 values(${i},'llll',123.4);" >> /opt/trafodion/xdc_automatic/sql/insert_p4.sql
done

