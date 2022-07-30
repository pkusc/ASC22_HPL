#!/bin/bash
#export OMP_PLACES='{144}:6:4'
#location of HPL 
HPL_DIR=`pwd`

#APP="$HPL_DIR/../../xhpl"
EXE=$1
APP=$HPL_DIR/../../$EXE
NB=$2

# Adapt here in particular if hpl_ai_job_submit.sh was NOT used to launch the job
# Number of CPU cores
# Total CPU cores / Total GPUs (not counting hyperthreading)

###CPU_CORES_PER_RANK=2
###export RANKS_PER_NODE=4
###export RANKS_PER_SOCKET=2

echo "CPU_CORES_PER_RANK is " $CPU_CORES_PER_RANK
if [[ -z "$CPU_CORES_PER_RANK" ]]
then
    echo "variable --CPU_CORES_PER_RANK-- is empty please set it"
    exit
fi

export OMP_NUM_THREADS=$CPU_CORES_PER_RANK
export MKL_NUM_THREADS=$CPU_CORES_PER_RANK



if [ $# -lt 4 ] 
then
    profile_rank_id=0
else
    profile_rank_id=$4
fi

profile=0
nvprofname=''


#export END_PROG=10
#export TEST_LOOPS=1


if [ $NB -lt 1536 ] 
then
    MNB=$NB
else
    MNB=6144
fi

#export PRI_GEMM=0

export USE_MANAGED=1
#export USE_ZERO_COPY=1
#export USE_COPY_KERNEL=1
export USE_LP_GEMM=3
export PAD_LDA_ODD=64
export FACT_IC_OS_ROWS=$MNB
export FACT_IC_OS_COLS=$NB

export MAX_H2D_MS=100
export MAX_D2H_MS=100
export NUM_WORK_BUF=3
#export GRID_STRIPE=6

export FACT_GEMM_PRINT=0
export FACT_GEMM=1
export FACT_GEMM_MIN=0
export SORT_RANKS=0
export PRINT_SCALE=2.0
export TEST_SYSTEM_PARAMS=0
export TEST_SYSTEM_PARAMS_COUNT=3

rm -rf /dev/shm/sh_*
#export END_PROG=5.0

export LIBC_FATAL_STDERR_=1
export CUDA_CACHE_PATH=/tmp
export CUDA_DEVICE_MAX_CONNECTIONS=16
export CUDA_COPY_SPLIT_THRESHOLD_MB=1
export GPU_DGEMM_SPLIT=1.0
export TRSM_CUTOFF=90000000
export GPU_GEMM_SPLIT=1.0

export MONITOR_GPU=1
export GPU_TEMP_WARNING=80
export GPU_CLOCK_WARNING=1328
export GPU_POWER_WARNING=290
export GPU_PCIE_GEN_WARNING=3
export GPU_PCIE_WIDTH_WARNING=16

export ICHUNK_SIZE=$NB
export CHUNK_SIZE=$MNB
export SCHUNK_SIZE=$MNB



nvidia-smi -ac 877,1380 > /dev/null
#sudo nvidia-smi -ac 877,1380 > /dev/null

lrank=$OMPI_COMM_WORLD_LOCAL_RANK

case ${lrank} in
0)
#ldd $APP
echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank 
  export CUDA_VISIBLE_DEVICES=0; numactl --cpunodebind=0  $APP
  ;;
1)

echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank 
  export CUDA_VISIBLE_DEVICES=1; numactl --cpunodebind=0  $APP
  ;;
2)
echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank 
  export CUDA_VISIBLE_DEVICES=2; numactl --cpunodebind=1  $APP
  ;;
3)
echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank 
  export CUDA_VISIBLE_DEVICES=3; numactl --cpunodebind=1  $APP
  ;;
esac

