#!/bin/bash


#update data with table named xdc
echo "update TRAFODION.XDC_TEST.XDC1 set name='tttt' where id = 201;" > /opt/trafodion/xdc_automatic/sql/update_other.sql
for((i=202;i<=300;i++));
do
echo "update TRAFODION.XDC_TEST.XDC1 set name='tttt' where id = ${i};" >>  /opt/trafodion/xdc_automatic/sql/update_other.sql
done


