#!/bin/bash
echo "######## Create a synchronous table named XDC1 now  ######### "
sqlci -i /opt/trafodion/xdc_automatic/sql/CreateSynTable.sql
echo "######## A synchronous table named XDC1 has been created ###"
