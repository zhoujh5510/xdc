#!/bin/bash


#update data with table named xdc
echo "update TRAFODION.XDC_TEST.XDC4 set name='mmmm' where id = 1;" > /opt/trafodion/xdc_automatic/sql/update_p4.sql
for((i=2;i<=300;i++));
do
echo "update TRAFODION.XDC_TEST.XDC4 set name='mmmm' where id = ${i};" >> /opt/trafodion/xdc_automatic/sql/update_p4.sql
done


