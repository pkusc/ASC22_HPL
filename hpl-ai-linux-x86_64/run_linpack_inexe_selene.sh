#!/bin/bash
#export OMP_PLACES='{144}:6:4'
#location of HPL 
HPL_DIR=`pwd`

#APP="$HPL_DIR/../../xhpl"
EXE=$1
APP=$HPL_DIR/$EXE

# Adapt here in particular if hpl_ai_job_submit.sh was NOT used to launch the job
# Number of CPU cores
# Total CPU cores / Total GPUs (not counting hyperthreading)

#export MKL_DEBUG_CPU_TYPE=5

CPU_CORES_PER_RANK=16
###export RANKS_PER_NODE=4
###export RANKS_PER_SOCKET=2

echo "CPU_CORES_PER_RANK is " $CPU_CORES_PER_RANK
if [[ -z "$CPU_CORES_PER_RANK" ]]
then
    echo "variable --CPU_CORES_PER_RANK-- is empty please set it"
    exit
fi
# Number of CPU cores
# Total CPU cores / Total GPUs (not counting hyperthreading)
export OMP_PROC_BIND=TRUE 
export OMP_PLACES=sockets

export OMP_NUM_THREADS=$CPU_CORES_PER_RANK
export MKL_NUM_THREADS=$CPU_CORES_PER_RANK


if [ $# -lt 1 ] 
then
    echo "no executable name run with ./run_linpack_inexeXX.sh exe_name  NB(optional: default 1536)  name_of_profiler_output(optional: default no profile)  profile_rank_id(optional: default 0)"
    exit
fi

if [ $# -lt 2 ] 
then
    NB=1536
else
    NB=$2
fi


if [ $# -lt 3 ] 
then
    profile=0
    nvprofname=
else
    nothing=0    
    nvname=$3 
    profile=1
    nvprofname=$nvname'_%h_%p_%q{OMPI_COMM_WORLD_RANK}.nvvp'
    export END_PROG=15
    export TEST_LOOPS=1
fi


if [ $# -lt 4 ] 
then
    profile_rank_id=0
else
    profile_rank_id=$4
fi


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
export FACT_GEMM_MIN=0 #32
export SORT_RANKS=0
export PRINT_SCALE=2.0
export TEST_SYSTEM_PARAMS=0 #1
export TEST_SYSTEM_PARAMS_COUNT=0 #3

#rm -rf /dev/shm/sh_*
#export END_PROG=5.0

export LIBC_FATAL_STDERR_=1
#export PAMI_ENABLE_STRIPING=0
export CUDA_CACHE_PATH=/tmp
export CUDA_DEVICE_MAX_CONNECTIONS=12
export CUDA_COPY_SPLIT_THRESHOLD_MB=1
export GPU_DGEMM_SPLIT=1.0
export TRSM_CUTOFF=90000000
export GPU_GEMM_SPLIT=1.0

#export MONITOR_GPU=1
#export GPU_TEMP_WARNING=70
#export GPU_CLOCK_WARNING=1330
#export GPU_POWER_WARNING=350
#export GPU_PCIE_GEN_WARNING=3
#export GPU_PCIE_WIDTH_WARNING=2

export ICHUNK_SIZE=$NB
export CHUNK_SIZE=$MNB
export SCHUNK_SIZE=$MNB

lrank=$OMPI_COMM_WORLD_LOCAL_RANK


if [ $profile -eq 1 ] && [ $PMIX_RANK -eq $profile_rank_id ]
then
    NV="nvprof --openmp-profiling off --profile-from-start off --profile-child-processes  --process-name \"MPI Rank %q{OMPI_COMM_WORLD_RANK}\" --context-name \"MPI Rank %q{OMPI_COMM_WORLD_RANK}\" -fo $nvprofname  "
    NV="nvprof --openmp-profiling off --profile-from-start off --profile-child-processes   -fo $nvprofname  "
    echo $NV $APP
else
    NV=
fi
#--annotate-mpi openmpi


case ${lrank} in
0)
sudo nvidia-smi -lgc 1380,1410
#sudo nvidia-smi -ac 1215,1380
export CUDA_VISIBLE_DEVICES=0
export UCX_NET_DEVICES=mlx5_0:1
$PRE_APP numactl --physcpubind=32-47 --membind=2 $APP
  ;;
1)
export CUDA_VISIBLE_DEVICES=1
export UCX_NET_DEVICES=mlx5_1:1
$PRE_APP numactl --physcpubind=48-63 --membind=3 $APP
  ;;
2)
export CUDA_VISIBLE_DEVICES=2
export UCX_NET_DEVICES=mlx5_2:1
$PRE_APP numactl --physcpubind=0-15 --membind=0 $APP
  ;;
3)
export CUDA_VISIBLE_DEVICES=3
export UCX_NET_DEVICES=mlx5_3:1
$PRE_APP numactl --physcpubind=16-31  --membind=1 $APP
  ;;
4)
export CUDA_VISIBLE_DEVICES=4
export UCX_NET_DEVICES=mlx5_6:1
$PRE_APP numactl --physcpubind=96-111 --membind=6 $APP
  ;;
5)
export CUDA_VISIBLE_DEVICES=5
export UCX_NET_DEVICES=mlx5_7:1
$PRE_APP numactl --physcpubind=112-127 --membind=7 $APP
  ;;
6)
export CUDA_VISIBLE_DEVICES=6
export UCX_NET_DEVICES=mlx5_8:1
$PRE_APP numactl --physcpubind=64-79 --membind=4 $APP
  ;;
7)
export CUDA_VISIBLE_DEVICES=7
export UCX_NET_DEVICES=mlx5_9:1
$PRE_APP numactl --physcpubind=80-95 --membind=5 $APP
  ;;
esac


