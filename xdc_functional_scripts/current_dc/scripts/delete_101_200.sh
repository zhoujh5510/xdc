#!/bin/bash


echo "delete from TRAFODION.XDC_TEST.XDC1 where id=300;" > /opt/trafodion/xdc_automatic/sql/delete_101_200.sql
for((i=301;i<=400;i++));
do
echo "delete from TRAFODION.XDC_TEST.XDC1 where id=${i};" >> /opt/trafodion/xdc_automatic/sql/delete_101_200.sql
done

