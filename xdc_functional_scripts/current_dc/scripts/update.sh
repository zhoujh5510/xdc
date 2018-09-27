#!/bin/bash


#update data with table named xdc
echo "update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = 1;" > /opt/trafodion/xdc_automatic/sql/update.sql
for((i=2;i<=100;i++));
do
echo "update TRAFODION.XDC_TEST.XDC1 set name='mmmm' where id = ${i};" >> /opt/trafodion/xdc_automatic/sql/update.sql
done


