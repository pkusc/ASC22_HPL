#!/bin/bash

RESULT_FILE=$1


/opt/openmpi/bin/mpirun -n 2 --bind-to none --hostfile single_hosts --mca orte_base_help_aggregate 0 \
	./hpl.sh --cpu-affinity 0:1 --cpu-cores-per-rank 16 --gpu-affinity 0:1 \
	--dat 2xA100_double.dat | tee $RESULT_FILE

