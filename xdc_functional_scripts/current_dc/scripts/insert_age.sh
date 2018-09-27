#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC1 values(1000,'llll',123.4,1);" > /opt/trafodion/xdc_automatic/sql/insert_age.sql
for((i=1002;i<=1050;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC1 values(${i},'llll',123.4,${i});" >> /opt/trafodion/xdc_automatic/sql/insert_age.sql
done

