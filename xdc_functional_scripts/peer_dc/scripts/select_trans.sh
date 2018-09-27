#!/bin/bash


echo "begin work;" > /opt/trafodion/xdc_automatic/sql/select_trans.sql
echo "select * from TRAFODION.XDC_TEST.XDC1;" >> /opt/trafodion/xdc_automatic/sql/select_trans.sql
echo "commit work;" >> /opt/trafodion/xdc_automatic/sql/select_trans.sql

for((i=2;i<=30;i++));
do
echo "begin work;" >> /opt/trafodion/xdc_automatic/sql/select_trans.sql
echo "select * from TRAFODION.XDC_TEST.XDC1;" >> /opt/trafodion/xdc_automatic/sql/select_trans.sql
echo "commit work;" >> /opt/trafodion/xdc_automatic/sql/select_trans.sql
done
