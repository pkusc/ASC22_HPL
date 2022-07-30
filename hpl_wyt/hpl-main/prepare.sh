#!/bin/bash
CLOCK=795
sudo nvidia-smi -pm 2
sudo nvidia-smi -lgc $CLOCK
ssh -t pyyjason@10.0.0.1 "sudo nvidia-smi -pm 1; sudo nvidia-smi -lgc $CLOCK"
 
