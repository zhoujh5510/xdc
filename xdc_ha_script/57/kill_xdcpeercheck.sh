#!/bin/bash

#kill xdc_peer_check
echo "kill process of xdc_peer_check"
rt=$(ps -ef | grep xdc_peer_check | grep -v grep | awk '{print $2}')
kill -9 $rt
echo "kill process of xdc_peer_check successfully"
