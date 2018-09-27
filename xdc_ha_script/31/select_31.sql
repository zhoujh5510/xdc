set schema seabase;
log /opt/trafodion/xdc_HA_script/ha_data/xdctest_select_31.log clear, CMDTEXT OFF
select * from xdc_test;
log off
exit
