#!/bin/bash
TEST_NAME=V100
DATETIME=`hostname`.`date +"%m%d.%H%M%S"`
mkdir ./results/HPL-$TEST_NAME-results-$DATETIME
echo "Results in folder ./results/HPL-$TEST_NAME-results-$DATETIME"
RESULT_FILE=$1

echo "RESULTS in $RESULT_FILE" >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary_with_detail.txt
echo "********************************************************************************************************************" >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary_with_detail.txt

echo "CLK=$CLK"  >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary_with_detail.txt
grep "xhpl binary"  $RESULT_FILE  >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary_with_detail.txt
grep "CPU_CORES_PER_RANK"  $RESULT_FILE  >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary_with_detail.txt
grep "Per-Process Host Memory Estimate:" $RESULT_FILE  >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary_with_detail.txt

grep -B 1 -A 5 "T/V                N    NB     P     Q               Time                 Gflops" $RESULT_FILE  >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary_with_detail.txt

echo "********************************************************************************************************************" >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary_with_detail.txt

# accumulated result summary
echo "RESULTS in $RESULT_FILE" >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary.txt
grep "PASS\|FAIL\|WR00C2C2\|WC00C2C2\|WC02L2L2\|WR02L2L2" $RESULT_FILE >> ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary.txt

# also save results from this run to seperate file and show at the end
#grep "WR00C2C2\|WC00C2C2\|WC02L2L2|WR02L2L2" $RESULT_FILE >> ./results/result_summary_this_run_temp.txt

cat ./results/HPL-$TEST_NAME-results-$DATETIME/result_summary.txt
