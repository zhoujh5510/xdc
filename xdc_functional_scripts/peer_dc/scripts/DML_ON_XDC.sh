#!/bin/bash


echo "insert into TRAFODION.XDC_TEST.XDC values(1,'llll',123.4);" > /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
for((i=2;i<=100;i++));
do
echo "insert into TRAFODION.XDC_TEST.XDC values(${i},'llll',123.4);" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
done

echo "upsert into TRAFODION.XDC_TEST.XDC values(301,'kkkk',234.5);" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
for((i=302;i<=400;i++));
do
echo "upsert into TRAFODION.XDC_TEST.XDC values(${i},'kkkk',234.5);" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
done

echo "upsert using load into TRAFODION.XDC_TEST.XDC values(401,'nnnn',345.6);" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
for((i=402;i<=500;i++));
do
echo "upsert using load into TRAFODION.XDC_TEST.XDC values(${i},'nnnn',345.6);" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
done

#update data with table named xdc
echo "update TRAFODION.XDC_TEST.XDC set name='mmmm' where id = 1;" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
for((i=2;i<=100;i++));
do
echo "update TRAFODION.XDC_TEST.XDC set name='mmmm' where id = ${i};" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
done


echo "delete from TRAFODION.XDC_TEST.XDC where id=1;" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
for((i=2;i<=100;i++));
do
echo "delete from TRAFODION.XDC_TEST.XDC where id=${i};" >> /opt/trafodion/xdc_automatic/sql/dml_on_xdc.sql
done
