#!/bin/bash

#stop name node
echo "stop zookeeper-server now !!!!"
su - root <<EOF
linux
sh /opt/trafodion/stop_zookeeper_31.sh
ssh 10.10.23.32
sh /opt/trafodion/stop_zookeeper_server.sh
exit
EOF

