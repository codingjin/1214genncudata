# exp_sketch_dump

Minimal pipeline for generating and profiling CUDA kernels from TVM sketch descriptions. Transforms TVM auto-scheduler sketches into standalone CUDA kernels, profiles them with NVIDIA Nsight Compute, and generates XGBoost-ready feature datasets.

## Quick Start

### One-Line Complete Pipeline (Recommended)
```bash
python run_pipeline.py                      # Complete workflow: generate → profile → dataset
```

### Step-by-Step
```bash
python genkernel.py                         # 1. Generate kernels from allkernels.json
bash run.sh                                 # 2. Build and profile all configurations
python generate_dataset.py                  # 3. Create dataset.csv for XGBoost
```

## Workflow

1. **Input**: TVM sketch file (`allkernels.json`) with multiple kernel configurations
2. **Generation**: `genkernel.py` creates CUDA kernels in `kernel/` directory
3. **Profiling**: `run.sh` builds and profiles with NCU → `ncu_results/*.csv`
4. **Dataset**: `generate_dataset.py` extracts 14 metrics → `dataset.csv`

## Essential Files

### Core Scripts
- `run_pipeline.py`: All-in-one pipeline orchestrator
- `genkernel.py`: CUDA kernel generator from TVM sketches
- `generate_dataset.py`: Dataset generator from NCU results
- `extract_ncu_metrics.py`: Metric extraction and scaling logic

### Input/Output
- `allkernels.json`: TVM sketch input (default, customizable with `-f`)
- `template/`: Template files (main.cpp, demo.cu, common.h)
- `kernel/`: Generated CUDA kernels (created by genkernel.py)
- `ncu_results/`: NCU profiling results (created by run.sh)
- `dataset.csv`: XGBoost-ready features (created by generate_dataset.py)

## Advanced Usage

### Custom Sketch File
```bash
python run_pipeline.py -f custom_sketches.json
```

### Skip Steps
```bash
python run_pipeline.py --skip-genkernel     # Use existing kernels
python run_pipeline.py --skip-profiling     # Use existing NCU results
```

### Manual Kernel Generation
```bash
python genkernel.py -f my_sketches.json
```

## GPU Compatibility

**Automatic Architecture Detection**: The build system automatically detects your GPU using `nvidia-smi` and compiles optimized code for your specific hardware.

### Verified on:
- ✅ NVIDIA RTX 4090/4080 (sm_89)
- ✅ NVIDIA RTX 3090/3080 (sm_86)
- ✅ NVIDIA A100 (sm_80)
- ✅ NVIDIA A30 (sm_80)
- ✅ NVIDIA V100 (sm_70)
- ✅ NVIDIA RTX 2080 Ti (sm_75)

### Manual Override (Optional)
```bash
# Force specific architecture (e.g., for cross-compilation)
cd build
cmake -DCONFIG_IDX=0 -DCUDA_ARCH=86 ..
```

**Note**: No manual configuration needed in most cases. The system automatically adapts to your GPU!

## Dataset Features

The generated `dataset.csv` contains 14 normalized metrics:
- `blocksize(k)`, `threads(k)`, `reg_thread(k)`: Thread configuration
- `shm_block(mb)`: Shared memory usage
- `occupancy`, `mem`, `compute`: Utilization metrics (0-1 range)
- `time(ms)`: Kernel execution time
- `global_load(m)`, `global_store(m)`: Global memory operations
- `shm_load(m)`, `shm_store(m)`: Shared memory operations
- `inst(m)`: Instructions executed
- `branchefficiency`: Branch efficiency (0-1 range)
