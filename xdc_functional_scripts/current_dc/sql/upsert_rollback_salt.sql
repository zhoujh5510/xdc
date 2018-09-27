set schema xdc_test;
begin work;
upsert into TRAFODION.XDC_TEST.XDC1 values(301,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(302,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(303,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(304,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(305,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(306,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(307,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(308,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(309,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(310,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(311,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(312,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(313,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(314,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(315,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(316,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(317,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(318,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(319,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(320,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(321,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(322,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(323,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(324,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(325,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(326,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(327,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(328,'kkkk',234.5);
upsert into TRAFODION.XDC_TEST.XDC1 values(329,'kkkk',234.5);
log /opt/trafodion/xdc_automatic/logs_salt/upsert_rollback.log clear, CMDTEXT OFF
select * from xdc1;
log off
exit
