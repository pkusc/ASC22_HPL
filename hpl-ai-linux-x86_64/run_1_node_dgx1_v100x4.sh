#!/bin/bash
#location of HPL
HPL_DIR=`pwd`


#module load cuda/9.0.103
#module load cuda/9.0.176
#module load cuda/9.1.85
#module load cuda/9.2.88


module list

nvidia-smi

mpirun --version

#cp HPL.dat_2x2_1_node_dgx_v100x4 HPL.dat

#cp HPL.dat_4-gpu_full-scan HPL.dat


TEST_NAME=dgx1_v100x4
DATETIME=`hostname`.`date +"%m%d.%H%M%S"`
mkdir ./results/HPL-$TEST_NAME-results-$DATETIME
echo "Results in folder ./results/HPL-$TEST_NAME-results-$DATETIME"
RESULT_FILE=./results/HPL-$TEST_NAME-results-$DATETIME/HPL-$TEST_NAME-results-$DATETIME-out.txt


nvidia-smi -pm 1

#sudo nvidia-smi -ac 877,1245  # base clock for PCIE V100
#sudo nvidia-smi -ac 877,1290
sudo nvidia-smi -ac 877,1380
#sudo nvidia-smi -rac



#nvprof --profile-child-processes -o 268k_NB8192_fp16_%p --profile-from-start off mpirun -np 4 -bind-to none  -x LD_LIBRARY_PATH  ./run_linpack_GPU_dgx1_4xv100 2>&1 | tee $RESULT_FILE
mpirun -np 4 -bind-to none  -x LD_LIBRARY_PATH  ./run_linpack_GPU_dgx1_4xv100 2>&1 | tee $RESULT_FILE


# accumulated result summary
echo "RESULTS in $RESULT_FILE" >> ./results/result_summary.txt
#rep "WR00C2C2\|WC00C2C2\|WC02L2L2\|WR02L2L2" $RESULT_FILE >> ./results/result_summary.txt

grep "Per-Process\|WC\|WR" $RESULT_FILE >> ./results/result_summary.txt
grep "Per-Process\|WC\|WR" $RESULT_FILE














