#!/bin/bash

RESULT_FILE=$1


/opt/openmpi/bin/mpirun -n 1 --bind-to none \
	./hpl.sh --cpu-affinity 0 --cpu-cores-per-rank 16 --gpu-affinity 0 \
	--dat 1xA100_double.dat | tee $RESULT_FILE

