#!/bin/bash


echo "delete from TRAFODION.XDC_TEST.XDC4 where id=1;" > /opt/trafodion/xdc_automatic/sql/delete_p4.sql
for((i=2;i<=100;i++));
do
echo "delete from TRAFODION.XDC_TEST.XDC4 where id=${i};" >> /opt/trafodion/xdc_automatic/sql/delete_p4.sql
done

