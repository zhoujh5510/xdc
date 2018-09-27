set schema xdc_test;
begin work;
upsert using load into TRAFODION.XDC_TEST.XDC1 values(401,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(402,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(403,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(404,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(405,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(406,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(407,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(408,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(409,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(410,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(411,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(412,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(413,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(414,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(415,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(416,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(417,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(418,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(419,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(420,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(421,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(422,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(423,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(424,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(425,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(426,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(427,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(428,'nnnn',345.6);
upsert using load into TRAFODION.XDC_TEST.XDC1 values(429,'nnnn',345.6);
log /opt/trafodion/xdc_automatic/logs_salt/upsert_useload_rollback.log clear, CMDTEXT OFF
select * from xdc1;
log off
exit
