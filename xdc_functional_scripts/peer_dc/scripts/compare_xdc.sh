#/bin/bash

#execute command on two clusters
pdsh -w 10.10.23.31,10.10.23.57 "sqlci -i  /opt/trafodion/xdc/log/select.sql | tee /opt/trafodion/xdc/log/select.log"
#ssh trafodion@10.10.23.32 > /dev/null 2>&1 << eeooff
#cd /opt/trafodion/xdc/log/


#change current file name
mv ./log/select.log ./log/select1.log

#scp file which in other cluster to current cluster
scp trafodion@10.10.23.32:/opt/trafodion/xdc/log/select.log ./log/

#compare two files 
diff ./log/select1.log ./log/select.log > /dev/null
if [ $? -eq 0 ]; then
	echo "same"
else
	echo "different"
fi
