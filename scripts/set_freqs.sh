num_gpus=$(nvidia-smi -L | wc -l)
echo "GPU_NUM = $num_gpus"
for ((i=0; i<num_gpus; i++)); do
	nvidia-smi -i $i -pm 1
	clocks=$(nvidia-smi -i $i -q -d SUPPORTED_CLOCKS | grep -F 'Memory' -A1 | head -n2)
	mem_clock="${clocks#*: }"
	mem_clock="${mem_clock%% MHz*}"
	nvidia-smi -i $i -ac "$mem_clock,$1"
done
