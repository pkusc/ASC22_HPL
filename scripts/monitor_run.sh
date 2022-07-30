OMPI_ALLOW_RUN_AS_ROOT=1
OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
FREQ=$1
TEST_NAME="$(date +%Y-%m-%d-%H-%M-%S)_freq_$FREQ.txt"
curdir=`pwd`
targetdir="/home/benchmark/hpl-21.4"
# change this line to the test load
cd ${targetdir}
echo `pwd`
nohup ./run.sh /data/hpl/frequency_$1.out > ${curdir}/nohup.out &
PID=$!
echo $PID
while [ : ]
do 
	ps -p $PID > /dev/null
	RET="$?"
	if [ $RET -ne 0 ]
	then
		echo "Done!"
		break
	fi
	nvidia-smi | grep "Default" | sed -En 's/[^0-9]*([0-9]+)[^0-9]*/\1 /gp' | awk -v date="$(date +%Y-%m-%d-%H-%M-%S)" '{print date,$3}' | tee -a $TEST_NAME
done
