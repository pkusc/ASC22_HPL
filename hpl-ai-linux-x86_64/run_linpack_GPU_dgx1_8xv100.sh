#!/bin/bash
#location of HPL 
HPL_DIR=`pwd`

CPU_CORES_PER_RANK=4
#CPU_CORES_PER_RANK=5
RANK_PER_NODE=8

#cho "CPU_CORES_PER_RANK= $CPU_CORES_PER_RANK"

export OMP_NUM_THREADS=$CPU_CORES_PER_RANK
export MKL_NUM_THREADS=$CPU_CORES_PER_RANK
export LD_LIBRARY_PATH=$HPL_DIR:$LD_LIBRARY_PATH

export MONITOR_GPU=1
export GPU_TEMP_WARNING=80
export GPU_CLOCK_WARNING=1392
export GPU_POWER_WARNING=280
export GPU_PCIE_GEN_WARNING=3
export GPU_PCIE_WIDTH_WARNING=16

#export CUDA_DEVICE_MAX_CONNECTIONS=16
#export TRSM_CUTOFF=16000
export TRSM_CUTOFF=1000000
#export GPU_DGEMM_SPLIT=1.00
export GPU_DGEMM_SPLIT=1.0
#export RANK_PERF=1100.0
#export CHECK_CPU_DGEMM_PERF=0
#export CPU_DGEMM_PERF_WARNING=1000.0

#export TEST_SYSTEM_PARAMS=0
#export TEST_LOOPS=10

#APP=$HPL_DIR/xhpl_cuda9.0.176_mkl_2018_ompi_1.10.2_gcc485_sm35_sm60_sm70_5_18_18
#APP=$HPL_DIR/xhpl_cuda9.0.176_mkl_2018_ompi_3.1.0_gcc485_sm35_sm60_sm70_5_18_18
#APP=$HPL_DIR/xhpl_cuda9.1.85_mkl_2018_ompi_1.10.2_gcc485_sm35_sm60_sm70_5_18_18
#APP=$HPL_DIR/xhpl_cuda9.1.85_mkl_2018_ompi_3.1.0_gcc485_sm35_sm60_sm70_5_18_18
#APP=$HPL_DIR/xhpl_cuda9.2.88_mkl_2018_ompi_1.10.2_gcc485_sm35_sm60_sm70_5_18_18
#APP=$HPL_DIR/xhpl_cuda9.2.88_mkl_2018_ompi_3.1.0_gcc485_sm35_sm60_sm70_5_18_18
APP=$HPL_DIR/xhpl_fp32_TC




#echo "xhpl binary= $APP"

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
  export CUDA_VISIBLE_DEVICES=2; numactl --cpunodebind=0  $APP

  ;;
3)
echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank
  export CUDA_VISIBLE_DEVICES=3; numactl --cpunodebind=0  $APP

  ;;
4)
echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank
  export CUDA_VISIBLE_DEVICES=4; numactl --cpunodebind=1  $APP

  ;;
5)
echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank
  export CUDA_VISIBLE_DEVICES=5; numactl --cpunodebind=1  $APP

  ;;
6)
echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank
  export CUDA_VISIBLE_DEVICES=6; numactl --cpunodebind=1  $APP

  ;;
7)
echo "host=$me rank= $OMPI_COMM_WORLD_RANK lrank = $lrank cores=$CPU_CORES_PER_RANK bin=$APP"

  #set GPU and CPU affinity of local rank
  export CUDA_VISIBLE_DEVICES=7; numactl --cpunodebind=1  $APP

  ;;

esac


