#!/bin/bash


#update data with table named xdc
echo "update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 300;" > /opt/trafodion/xdc_automatic/sql/update_101_200.sql
for((i=301;i<=400;i++));
do
echo "update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = ${i};" >> /opt/trafodion/xdc_automatic/sql/update_101_200.sql
done


