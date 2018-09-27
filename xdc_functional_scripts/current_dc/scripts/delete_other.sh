#!/bin/bash


echo "delete from TRAFODION.XDC_TEST.XDC1 where id=201;" > /opt/trafodion/xdc_automatic/sql/delete_other.sql
for((i=202;i<=300;i++));
do
echo "delete from TRAFODION.XDC_TEST.XDC1 where id=${i};" >> /opt/trafodion/xdc_automatic/sql/delete_other.sql
done

