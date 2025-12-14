# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a minimal pipeline for generating and profiling CUDA kernels from TVM sketch descriptions. The workflow takes TVM auto-scheduler sketch configurations and transforms them into standalone CUDA kernels for performance profiling with NVIDIA Nsight Compute (NCU).

## Build and Development Commands

### Quick Start: Complete Pipeline (Recommended)
```bash
python run_pipeline.py                      # Run complete pipeline (default: allkernels.json)
python run_pipeline.py -f custom.json       # Use custom sketch file
python run_pipeline.py --skip-genkernel     # Skip kernel generation
python run_pipeline.py --skip-profiling     # Skip profiling step
```

The all-in-one pipeline script (`run_pipeline.py`):
1. Generates CUDA kernels from TVM sketches
2. Builds and profiles all configurations with NCU
3. Extracts metrics and generates `dataset.csv` for XGBoost training

### Step-by-Step: Individual Commands

#### 1. Generate All Kernels and Profiling Script
```bash
python genkernel.py                    # Process sketches from allkernels.json (default)
python genkernel.py -f custom.json     # Process sketches from custom file
python genkernel.py --log-file my.json # Long form option
```

This script:
- Reads sketch file containing TVM auto-scheduler configurations (supports multiple lines)
- Accepts `--log-file` or `-f` parameter to specify input file (default: allkernels.json)
- For each configuration, generates (in `kernel/` directory):
  - CUDA kernel code (`kernel/kernel{idx}.cuh`)
  - Wrapper file (`kernel/kernel{idx}.cu`)
- Automatically generates a `run.sh` script that builds and profiles all configurations

#### 2. Build and Profile All Configurations
```bash
bash run.sh  # Builds and profiles all configurations sequentially
```

The auto-generated run.sh:
- For each configuration:
  - Runs CMake with the configuration index
  - Builds the specific executable
  - Executes NCU profiling with `--set full` for comprehensive metrics
- Results saved to `ncu_results/ncu_config_{idx}.csv`

#### 3. Generate XGBoost Dataset
```bash
python generate_dataset.py  # Extract metrics from all NCU results
```

This script:
- Scans `ncu_results/` for all `ncu_config_{idx}.csv` files
- Extracts and scales 14 metrics using `extract_ncu_metrics.py` logic
- Generates `dataset.csv` with normalized features ready for XGBoost training

### Manual Build for Specific Configuration
```bash
mkdir -p build && cd build
cmake -DCONFIG_IDX=0 ..                    # Build config 0 (auto-detect GPU)
cmake -DCONFIG_IDX=0 -DCUDA_ARCH=86 ..     # Build config 0 for sm_86 (RTX 3090)
make -j
cd ..
./build/kernel_0 <params>
```

### CUDA Architecture Configuration

The build system **automatically detects your GPU architecture** using `nvidia-smi` at CMake configuration time. This ensures optimal performance and portability across different machines.

#### How Auto-Detection Works
1. CMake runs `nvidia-smi --query-gpu=compute_cap` to detect GPU compute capability
2. Converts compute capability (e.g., "8.6") to architecture code (e.g., "86")
3. Compiles CUDA code specifically for your GPU's architecture
4. **Fallback**: If detection fails, compiles for all common architectures (sm_70, 75, 80, 86, 89, 90)

#### Verified GPUs
The auto-detection works seamlessly on:
- ✅ **RTX 4090/4080**: Auto-detects sm_89
- ✅ **RTX 3090/3080**: Auto-detects sm_86
- ✅ **A100**: Auto-detects sm_80
- ✅ **A30**: Auto-detects sm_80
- ✅ **V100**: Auto-detects sm_70
- ✅ **RTX 2080 Ti**: Auto-detects sm_75

#### Manual Override (Optional)
```bash
# Auto-detect (default, recommended)
cmake -DCONFIG_IDX=0 ..

# Force specific architecture
cmake -DCONFIG_IDX=0 -DCUDA_ARCH=86 ..

# Compile for multiple architectures (larger binary, universal compatibility)
cmake -DCONFIG_IDX=0 -DCUDA_ARCH="75;80;86;89" ..
```

**Note**: Auto-detection is recommended. Manual override is only needed for cross-compilation or when building on a machine without a GPU.

## Architecture

### Complete Pipeline Workflow

1. **TVM Sketch Input** (`allkernels.json`): Contains serialized TVM auto-scheduler state with scheduling primitives (SP, FSP, CHR, CA, etc.). Supports multiple configurations (one per line).

2. **Code Generation** (`genkernel.py`):
   - Creates `kernel/` directory for all generated files
   - Parses all lines in allkernels.json (or custom file via `-f` option)
   - For each configuration:
     - Extracts convolution parameters (N, H, W, CO, CI, KH, KW, strides, padding)
     - Creates TVM SearchTask and applies sketch scheduling steps
     - Validates GPU resource constraints (shared memory, thread count)
     - Lowers to TIR and builds CUDA kernel
     - Extracts grid/block dimensions from scheduling primitives
     - Generates `kernel/kernel{idx}.cuh` and `kernel/kernel{idx}.cu`
   - Generates unified run.sh for all configurations

3. **Templates** (`template/` directory):
   - `template/demo.cu`: CUDA wrapper template with placeholder comments for kernel injection
   - `template/main.cpp`: Host code that parses CLI arguments and calls conv_kernel_wrapper
   - `template/common.h`: Utility functions for tensor generation and CUDA error checking

4. **Build and Profiling** (`run.sh` - auto-generated):
   - For each configuration:
     - Builds specific executable with CMake
     - Profiles with NCU using `--set full` for comprehensive metrics
     - Saves results to `ncu_results/ncu_config_{idx}.csv`

5. **Metrics Extraction** (`extract_ncu_metrics.py`):
   - Extracts 14 key metrics from NCU CSV files
   - Applies unit conversions and scaling for ML features:
     - Block size, threads, registers (scaled to thousands)
     - Shared memory (bytes → MB)
     - Occupancy, memory %, compute % (percent → 0-1 range)
     - Duration (nanoseconds → milliseconds)
     - Memory operations (scaled to millions)
     - Instructions executed (scaled to millions)
     - Branch efficiency (percent → 0-1 range)

6. **Dataset Generation** (`generate_dataset.py`):
   - Scans `ncu_results/` for all profiling results
   - Uses `extract_ncu_metrics.py` logic to process each configuration
   - Generates `dataset.csv` with 14 normalized features for XGBoost training

7. **Generated Output**:
   - `kernel/` directory containing all generated files:
     - `kernel/kernel{idx}.cuh`: Generated CUDA kernel from TVM
     - `kernel/kernel{idx}.cu`: Instantiated template with kernel included
   - `run.sh`: Unified profiling script for all configurations
   - `build/kernel_{idx}`: Compiled executables
   - `ncu_results/ncu_config_{idx}.csv`: NCU profiling results
   - `dataset.csv`: XGBoost-ready feature dataset

### Key Code Structure

- **Kernel Wrapper Interface**: `conv_kernel_wrapper()` in template/demo.cu handles memory allocation, data transfer, and kernel launch
- **Parameter Flow**: template/main.cpp → conv_kernel_wrapper() → generated CUDA kernel
- **Grid/Block Calculation**: Extracted from TVM sketch's SP (split) primitives in genkernel.py
- **Template Organization**: All template files organized in `template/` directory for clarity

### TVM Sketch Primitives

The sketch.json uses TVM auto-scheduler primitives:
- `SP`: Split primitive (splits loop into multiple levels)
- `FSP`: Follow split after another stage
- `CHR`: Cache read (shared memory)
- `CA`: Compute at
- `RE`: Reorder
- `FU`: Fuse
- `AN`: Annotation
- `FFSP`: Follow fused split
- `CI`: Compute inline
- `PR`: Pragma

## Important Notes

- **All generated files organized in `kernel/` directory** - keeps project root clean
- **Generated kernels use function name pattern**: `kernel{idx}` (e.g., `kernel0`, `kernel1`) - clean names for easy NCU profiling
- Grid/block dimensions are computed from SP primitives with 4-length tile arrays
- CMakeLists.txt uses CONFIG_IDX variable to build specific configuration: `kernel_{CONFIG_IDX}` executable from `kernel/kernel{CONFIG_IDX}.cu`
- **CUDA architecture auto-detected by default** - uses `nvidia-smi` to query GPU compute capability, compiles for optimal performance on RTX 3090, RTX 4090, A100, A30, V100, and other modern GPUs
- **GPU resource validation** - genkernel.py validates shared memory and thread constraints before code generation
- Each configuration gets separate .cuh and .cu files to handle different tensor dimensions
- Host code generates 25 iterations of input/kernel data for profiling stability
- Convolution output dimensions: `N_X = (N_W - N_S + 2*padding)/strides + 1`
- run.sh rebuilds for each configuration to ensure correct kernel is linked
