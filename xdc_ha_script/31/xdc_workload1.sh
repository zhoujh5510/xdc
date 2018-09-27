#!/bin/bash

declare -a listProc
listProc[0]=$$,$0
log_dir="./log/"
batchNumber=10
tableName="TRAFODION.SEABASE.XDC_TEST"
timestamp=$(date +'%Y%m%d%H%M%S')
dcs_server="10.10.23.31:23400"
userName="db__root"
userPwd="traf123"

if [[ ! -d ${log_dir} ]];then
mkdir $log_dir
fi

echo -n "Please enter the paralle number(s): "
read answer

if [ $answer -lt 1 ]||[ $answer -gt 100 ]; then
     echo "Invalid parallel number"
     exit -1
fi
parallelNumber=$answer

echo -n "Please input the number of input rows: "
read answer
if [ $answer -lt 0 ]; then
        echo "Please Input a number(Greater than zero) of characters"
        exit -1
fi
rowNumbers=$answer

function prepareUD(){
	numberOfRows=`expr $1 \* 2`
	remainderNum=`expr $numberOfRows % $parallelNumber`
        tmpValue=`expr $numberOfRows - $remainderNum`
        rowsNumberPerInputFile=` expr $tmpValue / $parallelNumber `
        for ((j=0;j<$parallelNumber;j++));do
                tmpValue=`expr $j + 1`
                inputFile="./prepare_"$tmpValue".sql"
                echo "version;" > $inputFile
                echo "set time on;" >> $inputFile
                echo "set statistics on;" >> $inputFile
                echo "info session;" >> $inputFile
                echo "">>$inputFile
                echo "">>$inputFile
                startNumberOfPool=$(expr $rowsNumberPerInputFile*$j)
                endNumberOfPool=$(expr $rowsNumberPerInputFile*$tmpValue)
                if [ $tmpValue -eq $parallelNumber ];then
                        endNumberOfPool=$(expr $endNumberOfPool+$remainderNum)
                fi
                CreateprepareData $startNumberOfPool $endNumberOfPool $inputFile &
        done
}
function CreateprepareData(){
	for ((i=$1;i<$2;i++));do
                colkey=$i
                colint=`expr $numberOfRows - $i`
                GetRandomNumInSpecifiedRange 0 1000000
                colnum=$?
                colchariso=$(GetRandomRandmonStringFromAaToZz 11)
                colcharucs2=$(GetRandomRandmonStringFromAaToZz 11)
                GetRandomNumInSpecifiedRange 0 10000
                colintn=$?
                colcharison=$( GetRandomRandmonStringFromAaToZz 13)
                colcharucs2n=$(GetRandomRandmonStringFromAaToZz 13)
                echo "insert into ${tableName} values ($colkey, $colint, $colnum, '$colchariso', '$colcharucs2', $colintn, '$colcharison', '$colcharucs2n');" >> $3
	done
	trafci.sh -h $dcs_server -u $userName -p $userPwd -q "obey $3"
}

function prepareDML(){
        numberOfRows=$1
        remainderNum=`expr $numberOfRows % $parallelNumber`
        tmpValue=`expr $numberOfRows - $remainderNum`
        rowsNumberPerInputFile=` expr $tmpValue / $parallelNumber `
        for ((j=0;j<$parallelNumber;j++));do
                tmpValue=`expr $j + 1`
                inputFile="./dml_"$tmpValue".sql"
                echo "version;" > $inputFile
                echo "set time on;" >> $inputFile
                echo "set statistics on;" >> $inputFile
                echo "info session;" >> $inputFile
                echo "">>$inputFile
                echo "">>$inputFile
                startNumberOfPool=`expr $rowsNumberPerInputFile \* $j`
                endNumberOfPool=`expr $rowsNumberPerInputFile \* $tmpValue`
                if [ $tmpValue -eq $parallelNumber ];then
                        endNumberOfPool=$(expr $endNumberOfPool + $remainderNum)
                fi
                #echo "startNumberOfPool="$startNumberOfPool
                #echo "endNumberOfPool="$endNumberOfPool
		prepareDMLSql $startNumberOfPool $endNumberOfPool $inputFile &
	done
}

function prepareDMLSql(){
	for ((i=$1;i<$2;i++));do
		colkey=`expr $numberOfRows \* 2 + $i`
		colint=`expr $numberOfRows \* 3 - $i`
		GetRandomNumInSpecifiedRange 0 1000000
		colnum=$?
		colchariso=$(GetRandomRandmonStringFromAaToZz 11)
		colcharucs2=$(GetRandomRandmonStringFromAaToZz 11)
		GetRandomNumInSpecifiedRange 0 10000
		colintn=$?
		colcharison=$( GetRandomRandmonStringFromAaToZz 13)
		colcharucs2n=$(GetRandomRandmonStringFromAaToZz 13)
		GetRandomNumInSpecifiedRange 1 6
		dice=$?
		if [ ${dice} -lt 5 ];then
			echo "insert into ${tableName} values ($colkey, $colint, $colnum, '$colchariso', '$colcharucs2', $colintn, '$colcharison', '$colcharucs2n');" >> $3
		else
			echo "upsert into ${tableName} values ($colkey, $colint, $colnum, '$colchariso', '$colcharucs2', $colintn, '$colcharison', '$colcharucs2n');" >> $3
		fi
		GetRandomNumInSpecifiedRange 1 6
		dice=$?
		if [ ${dice} -lt 5 ];then
			echo "update ${tableName} set colnum=$colnum, colchariso='$colchariso', colcharucs2='$colcharucs2', colintn=$colintn, colcharison='$colcharison', colcharucs2n='$colcharucs2n' where colkey=${i};" >> $3
		else
			echo "upsert into ${tableName} values ($i, $colint, $colnum, '$colchariso', '$colcharucs2', $colintn, '$colcharison', '$colcharucs2n');" >> $3
		fi
		var=`expr $numberOfRows + $i`
		echo "delete from ${tableName} where colkey = ${var};" >>$3
	done
	if [ $batchNumber -gt 0 ];then
		rows=`expr $2 - $1`
		InsertTextIntoFileSpecifiedLine $3 $(expr 3 \* $rows)
	else 
		echo "exit;" >>$3
	fi
}

function InsertTextIntoFileSpecifiedLine(){
        fileName=$1
        rowsOfFile=$(($2 + 7))
        sed -i '6 abegin work;' $fileName
        for((i=$((7 + $batchNumber));i< $rowsOfFile;i += $(($batchNumber + 2)) ));do
                sed  $i' acommit work;' -i $fileName
                sed  $(( $i +1 ))' abegin work;' -i $fileName
                rowsOfFile=$(( $rowsOfFile + 2))
        done
        echo "commit work;" >>$fileName
        echo "exit;" >>$fileName
}

#***************Start: Get a random  String from A~Z and a~z   **************#
#
function GetRandomRandmonStringFromAaToZz(){
    basedString="q,w,e,r,t,y,u,i,o,p,a,s,d,f,g,h,j,k,l,z,x,c,v,b,n,m,Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M";
    #Split basedString to char arry
    OLD_IFS="$IFS"
    IFS=","
    arr=($basedString)
    IFS="$OLD_IFS"
    for((i=0;i<$1;i++))
    do
        GetRandomNumInSpecifiedRange 0 51
        randomNum=$?
        randomString=${randomString}${arr[$randomNum]}
    done
    echo $randomString
}
#
#*************** End : Get a random  String from A~Z and a~z   **************#
#


#
#***************Start: Get a random num in specified range     **************#
#
function GetRandomNumInSpecifiedRange(){
    minValue=$1
    maxiMumIncrement=$(($2-$min+1))
    num=$RANDOM
    #echo $(($num%$maxiMumIncrement+$minValue))
    return $(($num%$maxiMumIncrement+$minValue))
}
#
#*************** End : Get a random num in specified range     **************#
#
echo 'Prepare data for update & delete'
prepareUD $rowNumbers > /dev/null
prepareDML $rowNumbers
wait

function PrintfTestHeadInfo(){
        echo "###************************************************************************************************************###"
        echo "# #************************************************************************************************************# #"
        printf '# #                                      Test table name:%-30s                        # #\n' $tableName
        printf '# #                               Row numbers of testing:%-11i                                           # #\n' $1
        printf '# #                                   Parallel number(s):%-3i                                                   # #\n' $2
        printf '# #                        The number of batch operation:%-5i                                                 # #\n' $batchNumber
        echo "# #************************************************************************************************************# #"
        echo "###************************************************************************************************************###"
}

PrintfTestHeadInfo $rowNumbers $parallelNumber


echo -n "###    Complete the Prepare. Do you confirm the consistency of the data and begin test? (y/n):";
read answer
if [ $answer = Y ]||[ $answer = y ];then
        for ((i=1; i<=parallelNumber; i++))
        do
                tmp=${log_dir}dtm_${i}_${timestamp}.log
                echo ***$tmp
                (echo -e "obey ./old_dml_${i}.sql;\r\n"|trafci.sh -h $dcs_server -u $userName -p $userPwd 1>$tmp 2>&1) &
                pid=$!
                listProc[$i]=$pid,$tmp
                #echo ${listProc[$i]}
        done
else
        exit -1
fi

while :
do
    date
    tmp=0
    for ((i=0; i<=parallelNumber; i++))
    do
        if test $i -eq 0; then
            echo -e "\t$(date) ${listProc[$i]} is running."
            continue
        fi
        proc=$(echo ${listProc[$i]}|cut -d, -f1)
        if test $(ps -ef|grep $proc|grep -i trafci|wc -l) -eq 1; then
            echo -e "\t$(date) ${listProc[$i]} is running."
        else
            echo -e "\t$(date) ${listProc[$i]} is done."
            ((tmp+=1))
        fi
    done   
    if test $tmp -eq $parallelNumber; then
        for ((i=1; i<=parallelNumber; i++))
        do
            if test $(grep ERROR ${log_dir}dtm_${i}_${timestamp}.log|grep -v grep|wc -l) -ge 1; then
                echo -e "\t$(date) ${listProc[$i]} is failed."
            else
                echo -e "\t$(date) ${listProc[$i]} is pass."
            fi
        done
    fi
<<EOF
    if test $tmp -eq $parallelNumber; then
        echo "{"
        echo -e "$(date) Get execution time:"
        for ((i=1; i<=parallelNumber; i++))
        do
            echo "######Here"
            grep -H -n 'Execution Time' ${log_dir}dtm_${i}_${timestamp}.log|sed 's/ \{2,\}/ /g'|sed '1,2d'
        done
        echo "}"
    fi
EOF
    sleep 10
done

exit 0

