#!/bin/bash


echo "upsert into TRAFODION.XDC_TEST.XDC values(301,'kkkk',234.5);" > /opt/trafodion/xdc_automatic/sql/upsert_xdc.sql
for((i=302;i<=400;i++));
do
echo "upsert into TRAFODION.XDC_TEST.XDC values(${i},'kkkk',234.5);" >> /opt/trafodion/xdc_automatic/sql/upsert_xdc.sql
done

