import numpy as np
import tvm
from tvm import te, auto_scheduler, topi
from tvm.auto_scheduler.measure_record import load_record_from_string
import json
from tvm import te
from tvm import topi
import tvm.testing
import tvm.topi.testing
import os
import argparse

def get_verify_pass(valid, **kwargs):
    print(kwargs)
    def _fverify(f, *_):
        print(f)
        valid[0] = tvm.tir.analysis.verify_gpu_code(f, kwargs)
        return f

    return tvm.tir.transform.prim_func_pass(_fverify, opt_level=0)

def extract_values_from_json(line):
    # print(f"line: {line}")
    data = json.loads(line)
    value_str = data['i'][0][0]
    value_list = json.loads(value_str)
    pz = value_list[1:]
    # print(f"pz: {pz}")
    return pz

@auto_scheduler.register_workload
def conv2d(N, H, W, CO, CI, KH, KW, stride, padding):
    data = te.placeholder((N, CI, H, W), name="data")
    kernel = te.placeholder((CO, CI, KH, KW), name="kernel")
    conv = topi.nn.conv2d_nchw(data, kernel, stride, padding, dilation=1, out_dtype="float32")
    return [data, kernel, conv]

target = tvm.target.Target("cuda")

# Parse command line arguments
parser = argparse.ArgumentParser(description='Generate CUDA kernels from TVM sketch configurations')
parser.add_argument('--log-file', '-f', type=str, default='allkernels.json',
                    help='Path to the sketch JSON file (default: allkernels.json)')
args = parser.parse_args()

log_file = args.log_file

print(f"Reading sketch configurations from: {log_file}")
old_log = open(log_file, "r")
all_config = old_log.readlines()
assert len(all_config) > 0, "No configuration found in the log file."
print(f"Found {len(all_config)} configuration(s)")

str_headers = '''
#include <cassert>
#include <stdlib.h>
#include <cuda.h>

'''

class RecordProcessor:
    IDX_NODE_NAME = 0
    IDX_STAGE = 1
    IDX_ITER = 2
    IDX_LOOP_EXTENT = 3
    IDX_LENGTHS = 4
    IDX_INNER_TO_OUTER = 5
    IDX_TASK = 0
    IDX_STATE = 1
    IDX_TB = 2
    LENGTH_PAR_DIM = 4
    LENGTH_REDUC = 2

    def __init__(self, record):
        self.record = record
        self.json_str = json.loads(record)

file_path = "template/demo.cu"

# Create kernel directory for generated files
os.makedirs("kernel", exist_ok=True)

# Store all configurations for generating comprehensive run.sh
all_configs_data = []

for idx, line in enumerate(all_config):
    N, H, W, CO, CI, KH, KW, strides, padding = extract_values_from_json(line)
    task = auto_scheduler.SearchTask(
        func=conv2d, args=(N, H, W, CO, CI, KH, KW, strides, padding), target=target
    )
    inp, _ = load_record_from_string(line)
    # task.get_measure_state(tmp_file.name)
    sch, args = task.compute_dag.apply_steps_from_state(
            inp.state, task.layout_rewrite_option
        )
    ir_module = tvm.lower(sch, args)
    primfunc = ir_module["main"]
    from tvm.tir.analysis import verify_gpu_code
    valid = verify_gpu_code(primfunc, {"max_shared_memory_per_block": 48*1024, "max_threads_per_block": 1024})

    if valid != 1:
        print(f"\n{'='*60}")
        print(f"ERROR: GPU code validation failed for configuration {idx}")
        print(f"{'='*60}")
        print(f"Configuration parameters:")
        print(f"  N={N}, H={H}, W={W}, CO={CO}, CI={CI}, KH={KH}, KW={KW}")
        print(f"  Strides={strides}, Padding={padding}")
        print(f"\nValidation result: {valid}")
        print(f"This configuration exceeds GPU resource constraints.")
        print(f"{'='*60}\n")
        import sys
        sys.exit(1)

    print(f"Configuration {idx} validated successfully")
    
    func = tvm.build(sch, args, target)
    str_source = func.imported_modules[0].get_source()
    print("source code: ", str_source)
    
    # cut the string, start from the first extern
    str_source = str_source[str_source.find("extern"):]
    # replace "default_function_kernel" with "kernel{idx}" for cleaner profiling
    str_source = str_source.replace("default_function_kernel", f"kernel{idx}")
    
    # dump to file kernel/kernel{idx}.cuh
    with open(f"kernel/kernel{idx}.cuh", "w") as f:
        f.write(str_headers)
        f.write(str_source)
        
    # get parallel dimension tile list from the line
    processor = RecordProcessor(line)
    grid = 1
    block = 1
    for each in processor.json_str['i'][processor.IDX_STATE][1]:
        if each[processor.IDX_NODE_NAME] == "SP" and len(each[processor.IDX_LENGTHS]) == 4:

            dim_len = each[processor.IDX_LOOP_EXTENT]
            tile_list = each[processor.IDX_LENGTHS]
            # print("tile_list: ", tile_list)
            # print("dim_len: ", dim_len)
            
            grid *= dim_len/np.prod(tile_list)
            block *= tile_list[1]

    if grid <= 0 or block <= 0:
        print(f"Warning: Invalid grid={grid}, block={block}, using defaults")
        grid, block = 1, 256

    # Store configuration data for later run.sh generation
    all_configs_data.append({
        'idx': idx,
        'N': N, 'H': H, 'W': W,
        'CO': CO, 'CI': CI,
        'KH': KH, 'KW': KW,
        'strides': strides,
        'padding': padding,
        'grid': int(grid),
        'block': block
    })

    # Generate separate .cu file for this configuration
    output_path = f"kernel/kernel{idx}.cu"
    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        # Fix include path for common.h since we're in kernel/ subdirectory
        if '#include "common.h"' in line:
            new_lines.append(line.replace('#include "common.h"', '#include "../template/common.h"'))
        else:
            new_lines.append(line)

        if "// insert headers here" in line:
            # insert #include "kernel{idx}.cuh"
            new_lines.append(f"#include \"kernel{idx}.cuh\"\n")

        if "// insert kernel call here" in line:
            # insert dim3 size_grid_{idx} and dim3 size_block_{idx}
            new_lines.append(f"dim3 size_grid_{idx}({int(grid)},1,1);\n")
            new_lines.append(f"dim3 size_block_{idx}({block},1,1);\n")

            # TVM kernel signature: kernel(output, input, weights)
            new_lines.append(f"kernel{idx} <<< size_grid_{idx}, size_block_{idx} >>>(dev_Output, dev_Input, dev_Kernel);\n")

    with open(output_path, "w") as f:
        f.writelines(new_lines)

    print(f"Generated {output_path}")

# Generate build.sh and profile.sh for all configurations
print(f"\nGenerating build.sh and profile.sh for {len(all_configs_data)} configurations...")

# Generate build.sh
build_script = """#!/bin/bash
# Auto-generated build script for all sketch configurations
# Total configurations: """ + str(len(all_configs_data)) + """

mkdir -p build

"""

for config in all_configs_data:
    build_script += f"""
echo ""
echo "======================================"
echo "Building Configuration {config['idx']}"
echo "Parameters: N={config['N']} H={config['H']} W={config['W']} CO={config['CO']} CI={config['CI']} KH={config['KH']} KW={config['KW']}"
echo "Grid: {config['grid']}, Block: {config['block']}"
echo "======================================"

cd build
cmake -DCONFIG_IDX={config['idx']} ..
make -j
cd ..

"""

build_script += """
echo ""
echo "======================================"
echo "All builds completed!"
echo "Executables: ./build/kernel_*"
echo "======================================"
"""

with open("build.sh", "w") as f:
    f.write(build_script)

os.chmod("build.sh", 0o755)

# Generate profile.sh
profile_script = """#!/bin/bash
# Auto-generated profiling script for all sketch configurations
# Total configurations: """ + str(len(all_configs_data)) + """
#
# This script auto-detects GPU type and profiles at 5 different power cap settings
# Results are organized in ncu_results/powercap1/ through ncu_results/powercap5/

set -e  # Exit on error

echo "======================================"
echo "GPU Auto-Detection and Power Cap Setup"
echo "======================================"

# Detect GPU model
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader -i 0)
echo "Detected GPU: $GPU_NAME"

# Select power cap array based on GPU model
if [[ "$GPU_NAME" == *"RTX 3090"* ]]; then
    POWER_CAPS=(100 200 300 420 450)
    echo "GPU Type: RTX 3090"
elif [[ "$GPU_NAME" == *"RTX 4090"* ]]; then
    POWER_CAPS=(150 200 300 400 450)
    echo "GPU Type: RTX 4090"
elif [[ "$GPU_NAME" == *"A30"* ]]; then
    POWER_CAPS=(100 120 140 160 165)
    echo "GPU Type: A30"
elif [[ "$GPU_NAME" == *"V100"* ]]; then
    POWER_CAPS=(100 150 200 250 300)
    echo "GPU Type: V100"
elif [[ "$GPU_NAME" == *"A100"* ]]; then
    POWER_CAPS=(100 200 250 300 400)
    echo "GPU Type: A100"
else
    echo "ERROR: Unknown GPU model: $GPU_NAME"
    echo "Supported GPUs: RTX 3090, RTX 4090, A30, V100, A100"
    exit 1
fi

echo "Power cap settings: ${POWER_CAPS[@]} W"
echo ""

# Create base ncu_results directory
mkdir -p ncu_results

# Loop through all 5 power cap settings
for PC_IDX in {1..5}; do
    POWER_CAP=${POWER_CAPS[$((PC_IDX-1))]}
    OUTPUT_DIR="ncu_results/powercap${PC_IDX}"

    echo ""
    echo "======================================"
    echo "Power Cap ${PC_IDX}/5: ${POWER_CAP}W"
    echo "======================================"

    # Create output directory
    mkdir -p "$OUTPUT_DIR"

    # Set power cap
    echo "Setting GPU 0 power cap to ${POWER_CAP}W..."
    sudo nvidia-smi -i 0 -pl $POWER_CAP
    sleep 1  # Brief delay for power cap to take effect

    # Verify power cap was set
    ACTUAL_POWER=$(nvidia-smi -i 0 --query-gpu=power.limit --format=csv,noheader,nounits | awk '{print int($1)}')
    echo "GPU 0 power cap confirmed: ${ACTUAL_POWER}W"
    echo ""
"""

# Add profiling loop for each power cap
profile_script += """
    # Profile all configurations at this power cap
"""

for config in all_configs_data:
    profile_script += f"""
    echo "Profiling config {config['idx']} at ${{POWER_CAP}}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_{config['idx']}" ]; then
        echo "ERROR: ./build/kernel_{config['idx']} not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \\
        --set full \\
        --print-details all \\
        --csv \\
        --log-file "$OUTPUT_DIR/ncu_config_{config['idx']}.csv" \\
        ./build/kernel_{config['idx']} \\
        {config['N']} {config['H']} {config['W']} {config['CO']} {config['CI']} {config['KH']} {config['KW']} {config['strides'][0]} {config['padding'][0]}

"""

profile_script += """
    echo ""
    echo "Completed profiling at ${POWER_CAP}W"
    echo "Results saved to: $OUTPUT_DIR/"
    echo ""
done

echo ""
echo "======================================"
echo "All profiling completed!"
echo "======================================"
echo "Total configurations: """ + str(len(all_configs_data)) + """"
echo "Total power cap settings: 5"
echo "Total profiling runs: """ + str(len(all_configs_data) * 5) + """"
echo ""
echo "Results organized in:"
for PC_IDX in {1..5}; do
    echo "  - ncu_results/powercap${PC_IDX}/ (${POWER_CAPS[$((PC_IDX-1))]}W)"
done
echo ""
"""

with open("profile.sh", "w") as f:
    f.write(profile_script)

os.chmod("profile.sh", 0o755)

print(f"\nGenerated build.sh and profile.sh with {len(all_configs_data)} configurations")
print(f"\nGenerated files in kernel/ directory:")
for config in all_configs_data:
    print(f"  - kernel/kernel{config['idx']}.cuh")
    print(f"  - kernel/kernel{config['idx']}.cu")
print(f"\nGenerated scripts:")
print(f"  - build.sh (builds all configurations)")
print(f"  - profile.sh (auto-detects GPU and profiles at 5 power caps)")
print(f"\nUsage:")
print(f"  1. Build all: bash build.sh")
print(f"  2. Profile at all power caps: bash profile.sh")
print(f"     - Auto-detects GPU type (RTX 3090/4090, A30, V100, A100)")
print(f"     - Profiles at 5 power cap settings per GPU")
print(f"     - Results saved to ncu_results/powercap1/ through powercap5/")
print(f"  3. Generate dataset: python generate_dataset.py")
