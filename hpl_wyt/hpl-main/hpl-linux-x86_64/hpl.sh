#!/bin/bash

# FIXME - workaround for Singularity
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/opt/intel/oneapi/mkl/2022.0.1/lib/intel64/:$LD_LIBRARY_PATH:/opt/cuda-11.6/targets/x86_64-linux/lib/

# Global settings
export MONITOR_GPU=1
export GPU_TEMP_WARNING=78
export GPU_CLOCK_WARNING=1410
export GPU_POWER_WARNING=400
export GPU_PCIE_GEN_WARNING=3
export GPU_PCIE_WIDTH_WARNING=2
export TRSM_CUTOFF=9000000
export TEST_LOOPS=1
export MAX_H2D_MS=200
export MAX_D2H_MS=200
export OMP_PROC_BIND=TRUE 
export OMP_PLACES=sockets

# HPL specific
export CUDA_DEVICE_MAX_CONNECTIONS=16 #HPL
export GPU_DGEMM_SPLIT=1.00 #HPL
export MKL_DEBUG_CPU_TYPE=5 #HPL
export TEST_SYSTEM_PARAMS=1 #HPL-AI=0

# HPL-AI specific
export USE_LP_GEMM=3
export PAD_LDA_ODD=64
export NUM_WORK_BUF=3
export FACT_GEMM_PRINT=0
export FACT_GEMM=1
export FACT_GEMM_MIN=0 #32
export TEST_SYSTEM_PARAMS_COUNT=0

usage() {
  echo ""
  echo "$(basename $0) [OPTION]"
#  echo "    --clock <string>              comma seperated GPU memory and core clock"
#  echo "                                  settings"
  echo "    --config <string>             name of config with preset options ('dgx-a100'),"
  echo "                                  or path to a shell file"
  echo "    --cpu-affinity <string>       colon separated list of cpu (ranges of) indices"
  echo "    --cpu-cores-per-rank <num>    number of threads per rank"
  echo "    --dat <string>                path to HPL.dat"
  echo "    --gpu-affinity <string>       colon separated list of gpu indices"
  echo "    --mem-affinity <string>       colon separated list of memory indices"
  echo "    --ucx-affinity <string>       colon separated list of UCX devices"
  echo "    --xhpl-ai                     use the HPL-AI-NVIDIA benchmark"
  echo ""
  echo "Either --config or the combination of --cpu-affinity, --cpu-cores-per-rank,"
  echo "and --gpu-affinity is required. --config takes precedence."
  echo ""
  echo "Examples:"
  echo " mpirun ... $(basename $0) --config dgx-a100"
  echo " mpirun ... $(basename $0) --config /path/to/config.sh"
  echo " mpirun ... $(basename $0) --cpu-affinity 0:0:0:0:1:1:1:1 --cpu-cores-per-rank 4 --gpu-affinity 0:1:2:3:4:5:6:7"
}

info() {
  local msg=$*
  echo -e "INFO: ${msg}"
}

warning() {
  local msg=$*
  echo -e "WARNING: ${msg}"
}

error() {
  local msg=$*
  echo -e "ERROR: ${msg}"
  exit 1
}

set_config() {
  local config="$1"

  if [ -z "${config}" ]; then
    return 0
  fi

  case ${config} in
    dgx-a100 )
      CPU_AFFINITY="32-47:48-63:0-15:16-31:96-111:112-127:64-79:80-95"
      CPU_CORES_PER_RANK=16
      GPU_AFFINITY="0:1:2:3:4:5:6:7"
      MEM_AFFINITY="2:3:0:1:6:7:4:5"
      UCX_AFFINITY="mlx5_0:mlx5_1:mlx5_2:mlx5_3:mlx5_6:mlx5_7:mlx5_8:mlx5_9"
      GPU_CLOCK="1380,1410"
      ;;

    * )
      if [ -f ${config} ]; then
        source ${config}
      else
        error "unrecognized config: ${config}\nvalid preset config is 'dgx-a100', or a valid shell file"
      fi
  esac

}

read_rank() {
  # Global rank
  if [ -n "${OMPI_COMM_WORLD_RANK}" ]; then
    RANK=${OMPI_COMM_WORLD_RANK}
  elif [ -n "${PMI_RANK}" ]; then
    RANK=${PMI_RANK}
  else
    warning "could not determine rank"
  fi

  # Node local rank
  if [ -n "${OMPI_COMM_WORLD_LOCAL_RANK}" ]; then
    LOCAL_RANK=${OMPI_COMM_WORLD_LOCAL_RANK}
  elif [ -n "${SLURM_LOCALID}" ]; then
    LOCAL_RANK=${SLURM_LOCALID}
  else
    error "could not determine local rank"
  fi
}

# split the affinity string, e.g., '0:2:4:6' into an array,
# e.g., map[0]=0, map[1]=2, ...  The array index is the MPI rank.
read_cpu_affinity_map() {
    local affinity_string=$1
    readarray -t CPU_AFFINITY_MAP <<<"$(tr ':' '\n'<<<"$affinity_string")"
}

# split the affinity string, e.g., '0:2:4:6' into an array,
# e.g., map[0]=0, map[1]=2, ...  The array index is the MPI rank.
read_gpu_affinity_map() {
    local affinity_string=$1
    readarray -t GPU_AFFINITY_MAP <<<"$(tr ':' '\n'<<<"$affinity_string")"
}

# split the affinity string, e.g., '0:2:4:6' into an array,
# e.g., map[0]=0, map[1]=2, ...  The array index is the MPI rank.
read_mem_affinity_map() {
    local affinity_string=$1
    readarray -t MEM_AFFINITY_MAP <<<"$(tr ':' '\n'<<<"$affinity_string")"
}

# split the affinity string, e.g., '0:2:4:6' into an array,
# e.g., map[0]=0, map[1]=2, ...  The array index is the MPI rank.
read_ucx_affinity_map() {
    local affinity_string=$1
    readarray -t UCX_AFFINITY_MAP <<<"$(tr ':' '\n'<<<"$affinity_string")"
}

### main script starts here
# FIXME
XHPL=/home/jokerwyt/hpl-main/hpl-main/hpl-linux-x86_64/xhpl
# DAT=/workspace/hpl-linux-x86_64/HPL.dat

# Read command line arguments
while [ "$1" != "" ]; do
  case $1 in
    --clock )
      if [ -n "$2" ]; then
        GPU_CLOCK="$2"
      else
        usage
        exit 1
      fi
      shift
      ;;
    --config )
      if [ -n "$2" ]; then
        CONFIG="$2"
      else
        usage
	    exit 1
      fi
      shift
      ;;
    --cpu-affinity )
      if [ -n "$2" ]; then
        CPU_AFFINITY="$2"
      else
        usage
        exit 1
      fi
      shift
      ;;
    --cpu-cores-per-rank )
      if [ -n "$2" ]; then
        CPU_CORES_PER_RANK="$2"
      else
        usage
        exit 1
      fi
      shift
      ;;
    --dat )
      if [ -n "$2" ]; then
        DAT="$2"
      else
        usage
        exit 1
      fi
      shift
      ;;
    --gpu-affinity )
      if [ -n "$2" ]; then
        GPU_AFFINITY="$2"
      else
        usage
        exit 1
      fi
      shift
      ;;
    --mem-affinity )
      if [ -n "$2" ]; then
        MEM_AFFINITY="$2"
      else
        usage
        exit 1
      fi
      shift
      ;;
    --ucx-affinity )
      if [ -n "$2" ]; then
        UCX_AFFINITY="$2"
      else
        usage
        exit 1
      fi
      shift
      ;;
    --xhpl-ai )
      XHPL=~/workspace/hpl-ai-linux-x86_64/xhpl_ai
      ;;
  * )
    usage
    exit 1
  esac
  shift
done

# Set the config
if [ -n "${CONFIG}" ]; then
  set_config ${CONFIG}
fi

if [ -z "$CPU_AFFINITY" ] || [ -z "${GPU_AFFINITY}" ]; then
  error "necessary parameters not set, see $(basename $0) --help"
fi

# Figure out the right parameters for this particular rank
read_rank
read_cpu_affinity_map $CPU_AFFINITY
read_gpu_affinity_map $GPU_AFFINITY
read_mem_affinity_map $MEM_AFFINITY
read_ucx_affinity_map $UCX_AFFINITY


CPU=${CPU_AFFINITY_MAP[$LOCAL_RANK]}
GPU=${GPU_AFFINITY_MAP[$LOCAL_RANK]}
MEM=${MEM_AFFINITY_MAP[$LOCAL_RANK]}
UCX=${UCX_AFFINITY_MAP[$LOCAL_RANK]}

if [ -z "$CPU" ] || [ -z "$GPU" ] || [ -z "$CPU_CORES_PER_RANK" ]; then
  error "cpu and/or gpu values not set"
fi

if [ -z "$DAT" ]; then
  error "DAT file not provided"
fi

# if [ $LOCAL_RANK -eq 0 ]; then
#   sudo nvidia-smi -lgc ${GPU_CLOCK}
# fi
export CUDA_VISIBLE_DEVICES=${GPU}
export OMP_NUM_THREADS=${CPU_CORES_PER_RANK}
export MKL_NUM_THREADS=${CPU_CORES_PER_RANK}
if [ -n "${UCX}" ]; then
  export UCX_NET_DEVICES="$UCX:1"
fi
if [ -z "${MEM}" ]; then
  info "host=$(hostname) rank=${RANK} lrank=${LOCAL_RANK} cores=${CPU_CORES_PER_RANK} gpu=${GPU} cpu=${CPU} ucx=${UCX_NET_DEVICES} bin=$XHPL"
  echo numactl --cpunodebind=${CPU} ${XHPL} ${DAT}
  numactl --cpunodebind=${CPU} ${XHPL} ${DAT}

else
  info "host=$(hostname) rank=${RANK} lrank=${LOCAL_RANK} cores=${CPU_CORES_PER_RANK} gpu=${GPU} cpu=${CPU} mem=${MEM} ucx=${UCX_NET_DEVICES} bin=$XHPL"
  echo numactl --cpunodebind=${CPU} ${XHPL} ${DAT}
  numactl --physcpubind=${CPU} --membind=${MEM} ${XHPL} ${DAT}

fi
