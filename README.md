# genncudata

Minimal pipeline for generating and profiling CUDA kernels from TVM sketch descriptions. Transforms TVM auto-scheduler sketches into standalone CUDA kernels, profiles them with NVIDIA Nsight Compute, and generates XGBoost-ready feature datasets.

---

**📖 New to this project? Read [USAGE.md](USAGE.md) for a complete step-by-step guide!**

---

## Quick Start

### One-Line Complete Pipeline (Recommended)
```bash
python run_pipeline.py                      # Complete workflow: generate → profile → dataset

# With GPU setup (first-time or after reboot)
sudo python run_pipeline.py --setup-gpu     # GPU setup + complete workflow
```

### Step-by-Step
```bash
python genkernel.py                         # 1. Generate kernels + build.sh + profile.sh
bash build.sh                               # 2. Build all configurations
bash profile.sh                             # 3. Profile (uses current GPU power setting)
bash profile.sh 250                         # 3. OR profile at 250W
python generate_dataset.py                  # 4. Create dataset.csv for XGBoost
```

**Note**: `build.sh` and `profile.sh` are **auto-generated** by `genkernel.py`.

## GPU Setup (Recommended)

For optimal profiling performance, configure your GPU(s) before running the pipeline:

**Option 1: Integrated with pipeline (easiest)**
```bash
sudo python run_pipeline.py --setup-gpu     # GPU setup + full pipeline
```

**Option 2: Standalone script**
```bash
sudo ./setup_gpu.sh                         # One-time GPU configuration
```

This setup configures:
- ✓ Makes nvidia-smi passwordless (no sudo required for monitoring)
- ✓ Enables only GPU 0 for compute (disables other GPUs in multi-GPU systems)
- ✓ Enables persistent mode (reduces latency)
- ✓ Sets power cap to maximum (optimal performance)

**Note**: This is optional but recommended for consistent profiling results. Should be run once per system boot (or add to startup scripts).

## Workflow

1. **Input**: TVM sketch file (`allkernels.json`) with multiple kernel configurations
2. **Generation**: `genkernel.py` creates CUDA kernels in `kernel/` directory + auto-generates `build.sh` and `profile.sh`
3. **Build**: `build.sh` (auto-generated) compiles all configurations → `build/kernel_*` executables
4. **Profiling**: `profile.sh` (auto-generated) profiles with NCU → `ncu_results/*.csv`
   - No argument: uses current GPU power setting
   - With argument: sets GPU 0 power cap (e.g., `bash profile.sh 250` or `bash profile.sh max`)
5. **Dataset**: `generate_dataset.py` extracts 13 metrics → `dataset.csv`

## Essential Files

### Core Scripts
- `run_pipeline.py`: All-in-one pipeline orchestrator
- `genkernel.py`: CUDA kernel generator from TVM sketches
- `generate_dataset.py`: Dataset generator from NCU results
- `extract_ncu_metrics.py`: Metric extraction and scaling logic
- `setup_gpu.sh`: GPU configuration script (passwordless nvidia-smi, single GPU mode, persistent mode, max power)

### Input/Output
- `allkernels.json`: TVM sketch input (default, customizable with `-f`)
- `template/`: Template files (main.cpp, demo.cu, common.h)
- `kernel/`: Generated CUDA kernels (created by genkernel.py)
- `build.sh`: **Auto-generated** build script (created by genkernel.py)
- `profile.sh`: **Auto-generated** profiling script with power cap support (created by genkernel.py)
- `ncu_results/`: NCU profiling results (created by profile.sh)
- `dataset.csv`: XGBoost-ready features (created by generate_dataset.py)

## Advanced Usage

### Custom Sketch File
```bash
python run_pipeline.py -f custom_sketches.json
```

### Skip Steps
```bash
python run_pipeline.py --skip-genkernel     # Use existing kernels
python run_pipeline.py --skip-build         # Use existing executables
python run_pipeline.py --skip-profiling     # Use existing NCU results
```

### Profiling with Different Power Settings

The separated build/profile workflow allows you to build once and profile multiple times with different power caps.

**Important**:
- `profile.sh` is **auto-generated** by `genkernel.py`
- Without argument: **does NOT change** GPU power cap (uses current setting)
- With argument: **sets GPU 0 power cap** before profiling

```bash
# Build once
bash build.sh

# Profile at different power settings
bash profile.sh         # Profile at CURRENT power setting (no change)
bash profile.sh 200     # Set GPU 0 to 200W, then profile
bash profile.sh 250     # Set GPU 0 to 250W, then profile
bash profile.sh 300     # Set GPU 0 to 300W, then profile
bash profile.sh max     # Set GPU 0 to maximum power, then profile

# Or use the integrated pipeline
python run_pipeline.py --skip-build --power-cap 250
python run_pipeline.py --skip-build --skip-genkernel --power-cap 300
```

**Check current power setting:**
```bash
nvidia-smi --query-gpu=power.limit --format=csv
```

**Use Case**: Compare performance across different power budgets without rebuilding.

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

The generated `dataset.csv` contains 13 normalized metrics:
- `blocksize(k)`, `threads(k)`, `reg_thread(k)`: Thread configuration
- `shm_block(mb)`: Shared memory usage
- `occupancy`, `mem`, `compute`: Utilization metrics (0-1 range)
- `time(ms)`: Kernel execution time
- `global_load(m)`, `global_store(m)`: Global memory operations
- `shm_load(m)`, `shm_store(m)`: Shared memory operations
- `inst(m)`: Instructions executed
