#!/bin/bash
#location of HPL
HPL_DIR=`pwd`

#export PATH=/home-2/award/openmpi-1.10.2_installation_centos72_gcc485_no_cuda/bin:$PATH
#export LD_LIBRARY_PATH=/home-2/award/openmpi-1.10.2_installation_centos72_gcc485_no_cuda/lib:$LD_LIBRARY_PATH


#module load cuda/9.0.103
#module load cuda/9.0.176
#module load cuda/9.2.88


module list

nvidia-smi

mpirun --version

#cp HPL.dat_4x2_1_node_dgx_p100x8 HPL.dat
#cp HPL.dat_4x2_1_node_dgx_p100x8_b HPL.dat
#cp HPL.dat_4x2_1_node_dgx_v100x8 HPL.dat
#cp HPL.dat_8-gpu_nb128-scan HPL.dat
#cp HPL.dat_8-gpu_nb256-scan HPL.dat
cp HPL.dat_8-gpu_nb384-scan HPL.dat

TEST_NAME=dgx1_v100x8
DATETIME=`hostname`.`date +"%m%d.%H%M%S"`
mkdir ./results/HPL-$TEST_NAME-results-$DATETIME
echo "Results in folder ./results/HPL-$TEST_NAME-results-$DATETIME"
RESULT_FILE=./results/HPL-$TEST_NAME-results-$DATETIME/HPL-$TEST_NAME-results-$DATETIME-out.txt


nvidia-smi -pm 1

#sudo nvidia-smi -ac 877,1245  # base clock for PCIE V100
#sudo nvidia-smi -ac 877,1290
sudo nvidia-smi -ac 877,1380
#sudo nvidia-smi -rac



mpirun -np 8 -bind-to none  -x LD_LIBRARY_PATH ./run_linpack_GPU_dgx1_8xv100 2>&1 | tee $RESULT_FILE


# accumulated result summary
echo "RESULTS in $RESULT_FILE" >> ./results/result_summary.txt
#rep "WR00C2C2\|WC00C2C2\|WC02L2L2\|WR02L2L2" $RESULT_FILE >> ./results/result_summary.txt

grep "Per-Process\|WC\|WR" $RESULT_FILE >> ./results/result_summary.txt
grep "Per-Process\|WC\|WR" $RESULT_FILE




#mpirun -np 8 -bind-to none -x LD_LIBRARY_PATH ./run_linpack_GPU_dgx1_8xv100 | tee ./results/HPL-8xv100-results-$DATETIME/HPL-8xv100-results-$DATETIME-out.txt



