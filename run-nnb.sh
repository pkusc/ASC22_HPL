#!/bin/bash

RESULT_FILE=$1


/opt/openmpi/bin/mpirun -n 4 --bind-to none --hostfile hosts \
	./hpl.sh --cpu-affinity 0:1 --cpu-cores-per-rank 16 --gpu-affinity 0:1 --ucx-affinity mlx5_0:mlx5_0\
	--dat nnb.dat | tee $RESULT_FILE

