# Usage Guide

This guide shows you exactly how to run the TVM kernel profiling pipeline.

## Quick Start (Easiest Way)

### First Time: GPU Setup (Run Once)

```bash
# Configure GPU for optimal profiling (run once per boot, or add to startup scripts)
sudo ./setup_gpu.sh
```

This configures:
- Passwordless nvidia-smi
- Enable only GPU 0 (disables other GPUs in multi-GPU systems)
- Persistent mode for reduced latency
- Maximum power cap

**Important**: GPU setup persists until reboot. Run once per boot or add to startup scripts.

### Run the Complete Pipeline

```bash
# Run the full pipeline (validates GPU setup automatically)
python run_pipeline.py
```

This will:
1. **Validate GPU setup** (persistent mode, power cap, etc.)
2. Generate CUDA kernels from `allkernels.json`
3. Build all kernel executables
4. Profile all kernels with NCU
5. Create `dataset.csv` with 13 metrics

**After first run, you'll have:**
- `kernel/` - Generated CUDA kernels
- `build/` - Compiled executables
- `ncu_results/` - NCU profiling results
- `dataset.csv` - Ready for XGBoost training

---

## Normal Workflow

```bash
# 1. Setup GPU (once per boot)
sudo ./setup_gpu.sh

# 2. Run pipeline (validates GPU setup automatically)
python run_pipeline.py
```

The pipeline automatically validates that GPU has been configured correctly. If validation fails, it will tell you to run `sudo ./setup_gpu.sh`.

---

## Step-by-Step Workflow (More Control)

### Step 1: (Optional) Setup GPU
```bash
sudo ./setup_gpu.sh
```
Run once per boot, or skip if already done.

### Step 2: Generate Kernels
```bash
python genkernel.py                    # Uses allkernels.json
# OR
python genkernel.py -f custom.json     # Use custom sketch file
```

This creates:
- `kernel/kernel*.cuh` and `kernel/kernel*.cu` files
- `build.sh` script
- `profile.sh` script

### Step 3: Build All Kernels
```bash
bash build.sh
```

This compiles all configurations and creates `build/kernel_*` executables.

### Step 4: Profile All Kernels
```bash
bash profile.sh              # Profile with current GPU power setting
# OR
bash profile.sh 250          # Set GPU to 250W and profile
# OR
bash profile.sh max          # Set GPU to maximum power and profile
```

This creates NCU profiling results in `ncu_results/ncu_config_*.csv`.

### Step 5: Generate Dataset
```bash
python generate_dataset.py
```

This creates `dataset.csv` with 13 normalized metrics.

---

## Advanced: Profile at Multiple Power Levels

This is the main benefit of separated build/profile steps!

### Option 1: Using Scripts Directly
```bash
# Build once
python genkernel.py
bash build.sh

# Profile at different power levels
bash profile.sh 200
mv ncu_results ncu_results_200W
mkdir ncu_results

bash profile.sh 250
mv ncu_results ncu_results_250W
mkdir ncu_results

bash profile.sh 300
mv ncu_results ncu_results_300W
mkdir ncu_results

bash profile.sh max
mv ncu_results ncu_results_maxW

# Generate datasets for each power level
python generate_dataset.py  # You'll need to modify this to process specific ncu_results folders
```

### Option 2: Using Integrated Pipeline
```bash
# Build once
python run_pipeline.py

# Re-profile with different power settings (skips generation and build)
python run_pipeline.py --skip-genkernel --skip-build --power-cap 200
python run_pipeline.py --skip-genkernel --skip-build --power-cap 250
python run_pipeline.py --skip-genkernel --skip-build --power-cap 300
```

---

## Common Scenarios

### Scenario 1: "I just want everything to work"
```bash
# First time (or after reboot)
sudo ./setup_gpu.sh
python run_pipeline.py
```

### Scenario 2: "I already did GPU setup, just run the pipeline"
```bash
python run_pipeline.py
```

### Scenario 2b: "GPU validation failed, what do I do?"
```bash
# Run GPU setup
sudo ./setup_gpu.sh

# Try pipeline again
python run_pipeline.py
```

### Scenario 3: "I want to use a custom sketch file"
```bash
python run_pipeline.py -f my_sketches.json
```

### Scenario 4: "I only want to regenerate kernels, skip profiling"
```bash
python run_pipeline.py --skip-profiling
```

### Scenario 5: "I already built everything, just re-profile at 250W"
```bash
python run_pipeline.py --skip-genkernel --skip-build --power-cap 250
```

### Scenario 6: "I want to profile the same kernels at 200W, 250W, and 300W"
```bash
# Build once
python genkernel.py
bash build.sh

# Profile at each power level
bash profile.sh 200
# Copy/analyze results, then:
bash profile.sh 250
# Copy/analyze results, then:
bash profile.sh 300
```

---

## File Organization

After running the pipeline, you'll have:

```
project/
├── allkernels.json              # Input: TVM sketch configurations
├── genkernel.py                 # Script: Generate CUDA kernels
├── build.sh                     # Generated: Build script
├── profile.sh                   # Generated: Profile script with power cap support
├── run_pipeline.py              # All-in-one pipeline
├── setup_gpu.sh                 # GPU configuration script
├── generate_dataset.py          # Create XGBoost dataset
├── kernel/                      # Generated CUDA kernels
│   ├── kernel0.cuh
│   ├── kernel0.cu
│   ├── kernel1.cuh
│   ├── kernel1.cu
│   └── ...
├── build/                       # Compiled executables
│   ├── kernel_0
│   ├── kernel_1
│   └── ...
├── ncu_results/                 # NCU profiling results
│   ├── ncu_config_0.csv
│   ├── ncu_config_1.csv
│   └── ...
└── dataset.csv                  # XGBoost-ready dataset (13 metrics)
```

---

## Troubleshooting

### "ERROR: build.sh not found"
**Solution:** Run `python genkernel.py` first to generate the build script.

### "ERROR: ./build/kernel_0 not found"
**Solution:** Run `bash build.sh` before profiling.

### "Permission denied" when running setup_gpu.sh
**Solution:** Use `sudo ./setup_gpu.sh` or `sudo python run_pipeline.py --setup-gpu`

### Want to check GPU status
```bash
nvidia-smi  # Should work without sudo if you ran setup_gpu.sh
```

### Want to reset GPU settings
```bash
sudo nvidia-smi -c 0      # Enable all GPUs
sudo nvidia-smi -pm 0     # Disable persistent mode
```

---

## Summary

**Simplest workflow:**
```bash
sudo ./setup_gpu.sh        # First time (or after reboot)
python run_pipeline.py     # Run pipeline (validates GPU automatically)
```

**Manual workflow with power testing:**
```bash
sudo ./setup_gpu.sh        # Setup GPU once
python genkernel.py        # Generate kernels and scripts
bash build.sh              # Build once
bash profile.sh 200        # Profile at 200W
bash profile.sh 250        # Profile at 250W
bash profile.sh max        # Profile at max power
python generate_dataset.py # Create dataset
```

**Skip GPU validation (not recommended):**
```bash
python run_pipeline.py --skip-gpu-check
```
