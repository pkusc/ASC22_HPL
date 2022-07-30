#!/bin/bash

#export OMPI_ALLOW_RUN_AS_ROOT=1
#export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

RESULT_FILE=$1

cd /home/benchmark/hpl-21.4
/opt/openmpi/bin/mpirun -n 4 --bind-to none --hostfile hosts \
	./hpl.sh --cpu-affinity 0:1 --cpu-cores-per-rank 4 --gpu-affinity 0:1 \
	--dat best.dat

