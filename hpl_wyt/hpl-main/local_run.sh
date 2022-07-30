#!/bin/bash
RESULT_FILE=$1
/opt/openmpi/bin/mpirun -n 4 --bind-to none -x PATH -x LD_LIBRARY_PATH ./hpl-linux-x86_64/hpl.sh --cpu-affinity 0:0:1:1 --cpu-cores-per-rank 4 --gpu-affinity 0:0:1:1 --dat 4xA100-double.dat | tee $RESULT_FILE


