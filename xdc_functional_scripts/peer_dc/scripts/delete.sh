#!/bin/bash


echo "delete from TRAFODION.XDC_TEST.XDC1 where id=1;" > /opt/trafodion/xdc_automatic/sql/delete.sql
for((i=2;i<=100;i++));
do
echo "delete from TRAFODION.XDC_TEST.XDC1 where id=${i};" >> /opt/trafodion/xdc_automatic/sql/delete.sql
done

