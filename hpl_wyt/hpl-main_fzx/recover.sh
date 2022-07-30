#!/bin/bash
sudo nvidia-smi -rgc
ssh -t pyyjason@10.0.0.1 "sudo nvidia-smi -rgc"
