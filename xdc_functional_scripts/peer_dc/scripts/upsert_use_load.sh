#!/bin/bash


echo "upsert using load into TRAFODION.XDC_TEST.XDC1 values(401,'nnnn',345.6);" > /opt/trafodion/xdc_automatic/sql/upsert_use_load.sql
for((i=402;i<=500;i++));
do
echo "upsert using load into TRAFODION.XDC_TEST.XDC1 values(${i},'nnnn',345.6);" >> /opt/trafodion/xdc_automatic/sql/upsert_use_load.sql
done

