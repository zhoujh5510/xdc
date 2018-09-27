#!/bin/bash


echo "delete from TRAFODION.XDC_TEST.XDC1 where id=400;" > /opt/trafodion/xdc_automatic/sql/delete_400_300.sql
for((i=399;i>=300;i--));
do
echo "delete from TRAFODION.XDC_TEST.XDC1 where id=${i};" >> /opt/trafodion/xdc_automatic/sql/delete_400_300.sql
done

