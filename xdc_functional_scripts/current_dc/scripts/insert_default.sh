#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC1 values(1,default,123.4);" > /opt/trafodion/xdc_automatic/sql/insert_default.sql
for((i=2;i<=100;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC1 values(${i},default,123.4);" >> /opt/trafodion/xdc_automatic/sql/insert_default.sql
done

