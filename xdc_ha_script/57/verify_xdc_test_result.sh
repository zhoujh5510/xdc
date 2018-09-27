#!/bin/sh

helpInfo="
Description:this script is for verifing the difference of samen table's data between the DC1 and DC2
Usage: verify_xdc_test_result.sh [-Options <values>]
Options:
	-t <table name>		specify the target table name on both two dc;
	-h1 <ip address>	specify the DC1's dcs master ip adress;
	-h2 <ip address>        specify the DC2's dcs master ip adress;
	-h/--help		print the usage info." 	

tableName=TRAFODION.SEABASE.XDC_TEST;
DC1_IP=10.10.23.57;
DC2_IP=10.10.23.31;
dc1User="db__root"
dc1Pwd="traf123"
dc2User="db__root"
dc2Pwd="traf123"
selectResultFileName1="";
selectResultFileName2="";
function getAllValuesOfColkeyInFiles1(){
        numbersOfToatalRows=0;
	hostName=$1;
	selectResultFileName="./selectResult_in_"${hostName}".txt";	
        $MY_SQROOT/trafci/bin/trafci.sh -h "${hostName}:23400" -u "$dc1User" -p "$dc1Pwd" -q "select * from ${tableName} order by colkey asc;" > ./selectResult1.tmp
        grep '^\s' selectResult1.tmp >./$selectResultFileName
	#rm -f ./selectResult.tmp;
}

function getAllValuesOfColkeyInFiles2(){
        numbersOfToatalRows=0;
        hostName=$1;
        selectResultFileName="./selectResult_in_"${hostName}".txt";
        $MY_SQROOT/trafci/bin/trafci.sh -h "${hostName}:23400" -u "$dc2User" -p "$dc2Pwd" -q "select * from ${tableName} order by colkey asc;" > selectResult2.tmp
	grep '^\s' selectResult2.tmp >./$selectResultFileName
        #rm -f ./selectResult.tmp;
}

function getRowNumbersFromSelectResultFile(){
	selectResultFileName="./selectResult_in_"${hostName}".txt";
	str=`wc -l $selectResultFileName`;
        numbersOfToatalRows=`echo $str|cut -d " " -f1`;
        echo "The total row numbers of  this table :"${numbersOfToatalRows}
        return $numbersOfToatalRows;
}

while [[ $# -gt 0 ]] ; do
key="$1"; shift;
case ${key,,} in
	-t)		tableName="$1"; shift;;
	-h1)		DC1_IP="$1"; shift;;
	-h2)		DC2_IP="$1"; shift;;
	-h|--help)	echo -e "${helpInfo}"; exit 1;;
	*)		echo "Invalid input switch: $key"; echo -e "$USAGE"; exit 1;;
esac
done 

if [ -z $tableName ];then
        echo "tableName don't allowed to null"
        exit -1;
fi
#echo -n "Please enter one cluster IP of peer clusters:"
#read answer;
if [ -z $DC1_IP ];then
	echo "Ip don't allowed to null"
	exit -1;
fi

selectResultFileName1="./selectResult_in_"${DC1_IP}".txt";
getAllValuesOfColkeyInFiles1  $DC1_IP;

#echo -n "Please enter one cluster IP of another peer clusters:"
#read answer;
if [ -z $DC2_IP ];then
        echo "***ERROR:Ip don't allowed to null"
        exit -1;
elif [ $DC2_IP = DC1_IP ];then
	echo "***ERROR:Two Ip can't be same"
	exit -1
fi

selectResultFileName2="./selectResult_in_"${DC2_IP}".txt";
getAllValuesOfColkeyInFiles2  ${DC2_IP};

diff ${selectResultFileName1} ${selectResultFileName2};
if [ $? -ne 0 ];then 
	echo "***FAILED:The data dismatch between two peer clusters!!!"
	exit -1
fi
echo "***PASS:The data between two peer clusters is same";

