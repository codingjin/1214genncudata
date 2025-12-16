#!/bin/bash
# Auto-generated profiling script for all sketch configurations
# Total configurations: 175
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

    # Profile all configurations at this power cap

    echo "Profiling config 0 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_0" ]; then
        echo "ERROR: ./build/kernel_0 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_0.csv" \
        ./build/kernel_0 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 1 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_1" ]; then
        echo "ERROR: ./build/kernel_1 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_1.csv" \
        ./build/kernel_1 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 2 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_2" ]; then
        echo "ERROR: ./build/kernel_2 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_2.csv" \
        ./build/kernel_2 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 3 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_3" ]; then
        echo "ERROR: ./build/kernel_3 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_3.csv" \
        ./build/kernel_3 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 4 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_4" ]; then
        echo "ERROR: ./build/kernel_4 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_4.csv" \
        ./build/kernel_4 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 5 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_5" ]; then
        echo "ERROR: ./build/kernel_5 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_5.csv" \
        ./build/kernel_5 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 6 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_6" ]; then
        echo "ERROR: ./build/kernel_6 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_6.csv" \
        ./build/kernel_6 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 7 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_7" ]; then
        echo "ERROR: ./build/kernel_7 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_7.csv" \
        ./build/kernel_7 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 8 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_8" ]; then
        echo "ERROR: ./build/kernel_8 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_8.csv" \
        ./build/kernel_8 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 9 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_9" ]; then
        echo "ERROR: ./build/kernel_9 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_9.csv" \
        ./build/kernel_9 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 10 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_10" ]; then
        echo "ERROR: ./build/kernel_10 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_10.csv" \
        ./build/kernel_10 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 11 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_11" ]; then
        echo "ERROR: ./build/kernel_11 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_11.csv" \
        ./build/kernel_11 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 12 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_12" ]; then
        echo "ERROR: ./build/kernel_12 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_12.csv" \
        ./build/kernel_12 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 13 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_13" ]; then
        echo "ERROR: ./build/kernel_13 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_13.csv" \
        ./build/kernel_13 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 14 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_14" ]; then
        echo "ERROR: ./build/kernel_14 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_14.csv" \
        ./build/kernel_14 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 15 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_15" ]; then
        echo "ERROR: ./build/kernel_15 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_15.csv" \
        ./build/kernel_15 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 16 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_16" ]; then
        echo "ERROR: ./build/kernel_16 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_16.csv" \
        ./build/kernel_16 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 17 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_17" ]; then
        echo "ERROR: ./build/kernel_17 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_17.csv" \
        ./build/kernel_17 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 18 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_18" ]; then
        echo "ERROR: ./build/kernel_18 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_18.csv" \
        ./build/kernel_18 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 19 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_19" ]; then
        echo "ERROR: ./build/kernel_19 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_19.csv" \
        ./build/kernel_19 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 20 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_20" ]; then
        echo "ERROR: ./build/kernel_20 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_20.csv" \
        ./build/kernel_20 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 21 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_21" ]; then
        echo "ERROR: ./build/kernel_21 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_21.csv" \
        ./build/kernel_21 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 22 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_22" ]; then
        echo "ERROR: ./build/kernel_22 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_22.csv" \
        ./build/kernel_22 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 23 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_23" ]; then
        echo "ERROR: ./build/kernel_23 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_23.csv" \
        ./build/kernel_23 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 24 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_24" ]; then
        echo "ERROR: ./build/kernel_24 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_24.csv" \
        ./build/kernel_24 \
        1 272 272 64 32 3 3 1 1


    echo "Profiling config 25 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_25" ]; then
        echo "ERROR: ./build/kernel_25 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_25.csv" \
        ./build/kernel_25 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 26 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_26" ]; then
        echo "ERROR: ./build/kernel_26 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_26.csv" \
        ./build/kernel_26 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 27 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_27" ]; then
        echo "ERROR: ./build/kernel_27 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_27.csv" \
        ./build/kernel_27 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 28 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_28" ]; then
        echo "ERROR: ./build/kernel_28 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_28.csv" \
        ./build/kernel_28 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 29 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_29" ]; then
        echo "ERROR: ./build/kernel_29 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_29.csv" \
        ./build/kernel_29 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 30 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_30" ]; then
        echo "ERROR: ./build/kernel_30 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_30.csv" \
        ./build/kernel_30 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 31 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_31" ]; then
        echo "ERROR: ./build/kernel_31 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_31.csv" \
        ./build/kernel_31 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 32 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_32" ]; then
        echo "ERROR: ./build/kernel_32 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_32.csv" \
        ./build/kernel_32 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 33 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_33" ]; then
        echo "ERROR: ./build/kernel_33 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_33.csv" \
        ./build/kernel_33 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 34 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_34" ]; then
        echo "ERROR: ./build/kernel_34 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_34.csv" \
        ./build/kernel_34 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 35 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_35" ]; then
        echo "ERROR: ./build/kernel_35 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_35.csv" \
        ./build/kernel_35 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 36 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_36" ]; then
        echo "ERROR: ./build/kernel_36 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_36.csv" \
        ./build/kernel_36 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 37 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_37" ]; then
        echo "ERROR: ./build/kernel_37 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_37.csv" \
        ./build/kernel_37 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 38 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_38" ]; then
        echo "ERROR: ./build/kernel_38 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_38.csv" \
        ./build/kernel_38 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 39 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_39" ]; then
        echo "ERROR: ./build/kernel_39 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_39.csv" \
        ./build/kernel_39 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 40 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_40" ]; then
        echo "ERROR: ./build/kernel_40 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_40.csv" \
        ./build/kernel_40 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 41 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_41" ]; then
        echo "ERROR: ./build/kernel_41 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_41.csv" \
        ./build/kernel_41 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 42 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_42" ]; then
        echo "ERROR: ./build/kernel_42 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_42.csv" \
        ./build/kernel_42 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 43 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_43" ]; then
        echo "ERROR: ./build/kernel_43 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_43.csv" \
        ./build/kernel_43 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 44 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_44" ]; then
        echo "ERROR: ./build/kernel_44 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_44.csv" \
        ./build/kernel_44 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 45 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_45" ]; then
        echo "ERROR: ./build/kernel_45 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_45.csv" \
        ./build/kernel_45 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 46 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_46" ]; then
        echo "ERROR: ./build/kernel_46 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_46.csv" \
        ./build/kernel_46 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 47 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_47" ]; then
        echo "ERROR: ./build/kernel_47 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_47.csv" \
        ./build/kernel_47 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 48 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_48" ]; then
        echo "ERROR: ./build/kernel_48 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_48.csv" \
        ./build/kernel_48 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 49 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_49" ]; then
        echo "ERROR: ./build/kernel_49 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_49.csv" \
        ./build/kernel_49 \
        1 68 68 256 128 3 3 1 1


    echo "Profiling config 50 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_50" ]; then
        echo "ERROR: ./build/kernel_50 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_50.csv" \
        ./build/kernel_50 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 51 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_51" ]; then
        echo "ERROR: ./build/kernel_51 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_51.csv" \
        ./build/kernel_51 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 52 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_52" ]; then
        echo "ERROR: ./build/kernel_52 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_52.csv" \
        ./build/kernel_52 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 53 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_53" ]; then
        echo "ERROR: ./build/kernel_53 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_53.csv" \
        ./build/kernel_53 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 54 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_54" ]; then
        echo "ERROR: ./build/kernel_54 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_54.csv" \
        ./build/kernel_54 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 55 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_55" ]; then
        echo "ERROR: ./build/kernel_55 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_55.csv" \
        ./build/kernel_55 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 56 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_56" ]; then
        echo "ERROR: ./build/kernel_56 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_56.csv" \
        ./build/kernel_56 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 57 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_57" ]; then
        echo "ERROR: ./build/kernel_57 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_57.csv" \
        ./build/kernel_57 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 58 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_58" ]; then
        echo "ERROR: ./build/kernel_58 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_58.csv" \
        ./build/kernel_58 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 59 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_59" ]; then
        echo "ERROR: ./build/kernel_59 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_59.csv" \
        ./build/kernel_59 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 60 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_60" ]; then
        echo "ERROR: ./build/kernel_60 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_60.csv" \
        ./build/kernel_60 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 61 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_61" ]; then
        echo "ERROR: ./build/kernel_61 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_61.csv" \
        ./build/kernel_61 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 62 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_62" ]; then
        echo "ERROR: ./build/kernel_62 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_62.csv" \
        ./build/kernel_62 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 63 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_63" ]; then
        echo "ERROR: ./build/kernel_63 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_63.csv" \
        ./build/kernel_63 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 64 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_64" ]; then
        echo "ERROR: ./build/kernel_64 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_64.csv" \
        ./build/kernel_64 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 65 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_65" ]; then
        echo "ERROR: ./build/kernel_65 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_65.csv" \
        ./build/kernel_65 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 66 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_66" ]; then
        echo "ERROR: ./build/kernel_66 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_66.csv" \
        ./build/kernel_66 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 67 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_67" ]; then
        echo "ERROR: ./build/kernel_67 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_67.csv" \
        ./build/kernel_67 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 68 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_68" ]; then
        echo "ERROR: ./build/kernel_68 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_68.csv" \
        ./build/kernel_68 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 69 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_69" ]; then
        echo "ERROR: ./build/kernel_69 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_69.csv" \
        ./build/kernel_69 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 70 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_70" ]; then
        echo "ERROR: ./build/kernel_70 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_70.csv" \
        ./build/kernel_70 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 71 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_71" ]; then
        echo "ERROR: ./build/kernel_71 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_71.csv" \
        ./build/kernel_71 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 72 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_72" ]; then
        echo "ERROR: ./build/kernel_72 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_72.csv" \
        ./build/kernel_72 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 73 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_73" ]; then
        echo "ERROR: ./build/kernel_73 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_73.csv" \
        ./build/kernel_73 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 74 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_74" ]; then
        echo "ERROR: ./build/kernel_74 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_74.csv" \
        ./build/kernel_74 \
        1 34 34 512 256 3 3 1 1


    echo "Profiling config 75 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_75" ]; then
        echo "ERROR: ./build/kernel_75 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_75.csv" \
        ./build/kernel_75 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 76 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_76" ]; then
        echo "ERROR: ./build/kernel_76 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_76.csv" \
        ./build/kernel_76 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 77 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_77" ]; then
        echo "ERROR: ./build/kernel_77 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_77.csv" \
        ./build/kernel_77 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 78 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_78" ]; then
        echo "ERROR: ./build/kernel_78 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_78.csv" \
        ./build/kernel_78 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 79 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_79" ]; then
        echo "ERROR: ./build/kernel_79 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_79.csv" \
        ./build/kernel_79 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 80 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_80" ]; then
        echo "ERROR: ./build/kernel_80 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_80.csv" \
        ./build/kernel_80 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 81 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_81" ]; then
        echo "ERROR: ./build/kernel_81 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_81.csv" \
        ./build/kernel_81 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 82 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_82" ]; then
        echo "ERROR: ./build/kernel_82 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_82.csv" \
        ./build/kernel_82 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 83 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_83" ]; then
        echo "ERROR: ./build/kernel_83 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_83.csv" \
        ./build/kernel_83 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 84 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_84" ]; then
        echo "ERROR: ./build/kernel_84 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_84.csv" \
        ./build/kernel_84 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 85 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_85" ]; then
        echo "ERROR: ./build/kernel_85 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_85.csv" \
        ./build/kernel_85 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 86 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_86" ]; then
        echo "ERROR: ./build/kernel_86 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_86.csv" \
        ./build/kernel_86 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 87 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_87" ]; then
        echo "ERROR: ./build/kernel_87 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_87.csv" \
        ./build/kernel_87 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 88 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_88" ]; then
        echo "ERROR: ./build/kernel_88 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_88.csv" \
        ./build/kernel_88 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 89 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_89" ]; then
        echo "ERROR: ./build/kernel_89 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_89.csv" \
        ./build/kernel_89 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 90 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_90" ]; then
        echo "ERROR: ./build/kernel_90 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_90.csv" \
        ./build/kernel_90 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 91 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_91" ]; then
        echo "ERROR: ./build/kernel_91 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_91.csv" \
        ./build/kernel_91 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 92 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_92" ]; then
        echo "ERROR: ./build/kernel_92 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_92.csv" \
        ./build/kernel_92 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 93 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_93" ]; then
        echo "ERROR: ./build/kernel_93 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_93.csv" \
        ./build/kernel_93 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 94 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_94" ]; then
        echo "ERROR: ./build/kernel_94 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_94.csv" \
        ./build/kernel_94 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 95 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_95" ]; then
        echo "ERROR: ./build/kernel_95 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_95.csv" \
        ./build/kernel_95 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 96 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_96" ]; then
        echo "ERROR: ./build/kernel_96 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_96.csv" \
        ./build/kernel_96 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 97 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_97" ]; then
        echo "ERROR: ./build/kernel_97 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_97.csv" \
        ./build/kernel_97 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 98 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_98" ]; then
        echo "ERROR: ./build/kernel_98 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_98.csv" \
        ./build/kernel_98 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 99 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_99" ]; then
        echo "ERROR: ./build/kernel_99 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_99.csv" \
        ./build/kernel_99 \
        1 17 17 1024 512 3 3 1 1


    echo "Profiling config 100 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_100" ]; then
        echo "ERROR: ./build/kernel_100 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_100.csv" \
        ./build/kernel_100 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 101 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_101" ]; then
        echo "ERROR: ./build/kernel_101 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_101.csv" \
        ./build/kernel_101 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 102 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_102" ]; then
        echo "ERROR: ./build/kernel_102 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_102.csv" \
        ./build/kernel_102 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 103 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_103" ]; then
        echo "ERROR: ./build/kernel_103 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_103.csv" \
        ./build/kernel_103 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 104 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_104" ]; then
        echo "ERROR: ./build/kernel_104 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_104.csv" \
        ./build/kernel_104 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 105 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_105" ]; then
        echo "ERROR: ./build/kernel_105 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_105.csv" \
        ./build/kernel_105 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 106 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_106" ]; then
        echo "ERROR: ./build/kernel_106 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_106.csv" \
        ./build/kernel_106 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 107 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_107" ]; then
        echo "ERROR: ./build/kernel_107 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_107.csv" \
        ./build/kernel_107 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 108 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_108" ]; then
        echo "ERROR: ./build/kernel_108 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_108.csv" \
        ./build/kernel_108 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 109 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_109" ]; then
        echo "ERROR: ./build/kernel_109 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_109.csv" \
        ./build/kernel_109 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 110 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_110" ]; then
        echo "ERROR: ./build/kernel_110 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_110.csv" \
        ./build/kernel_110 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 111 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_111" ]; then
        echo "ERROR: ./build/kernel_111 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_111.csv" \
        ./build/kernel_111 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 112 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_112" ]; then
        echo "ERROR: ./build/kernel_112 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_112.csv" \
        ./build/kernel_112 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 113 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_113" ]; then
        echo "ERROR: ./build/kernel_113 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_113.csv" \
        ./build/kernel_113 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 114 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_114" ]; then
        echo "ERROR: ./build/kernel_114 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_114.csv" \
        ./build/kernel_114 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 115 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_115" ]; then
        echo "ERROR: ./build/kernel_115 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_115.csv" \
        ./build/kernel_115 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 116 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_116" ]; then
        echo "ERROR: ./build/kernel_116 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_116.csv" \
        ./build/kernel_116 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 117 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_117" ]; then
        echo "ERROR: ./build/kernel_117 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_117.csv" \
        ./build/kernel_117 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 118 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_118" ]; then
        echo "ERROR: ./build/kernel_118 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_118.csv" \
        ./build/kernel_118 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 119 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_119" ]; then
        echo "ERROR: ./build/kernel_119 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_119.csv" \
        ./build/kernel_119 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 120 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_120" ]; then
        echo "ERROR: ./build/kernel_120 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_120.csv" \
        ./build/kernel_120 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 121 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_121" ]; then
        echo "ERROR: ./build/kernel_121 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_121.csv" \
        ./build/kernel_121 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 122 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_122" ]; then
        echo "ERROR: ./build/kernel_122 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_122.csv" \
        ./build/kernel_122 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 123 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_123" ]; then
        echo "ERROR: ./build/kernel_123 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_123.csv" \
        ./build/kernel_123 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 124 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_124" ]; then
        echo "ERROR: ./build/kernel_124 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_124.csv" \
        ./build/kernel_124 \
        1 56 56 64 64 3 3 1 1


    echo "Profiling config 125 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_125" ]; then
        echo "ERROR: ./build/kernel_125 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_125.csv" \
        ./build/kernel_125 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 126 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_126" ]; then
        echo "ERROR: ./build/kernel_126 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_126.csv" \
        ./build/kernel_126 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 127 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_127" ]; then
        echo "ERROR: ./build/kernel_127 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_127.csv" \
        ./build/kernel_127 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 128 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_128" ]; then
        echo "ERROR: ./build/kernel_128 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_128.csv" \
        ./build/kernel_128 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 129 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_129" ]; then
        echo "ERROR: ./build/kernel_129 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_129.csv" \
        ./build/kernel_129 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 130 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_130" ]; then
        echo "ERROR: ./build/kernel_130 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_130.csv" \
        ./build/kernel_130 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 131 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_131" ]; then
        echo "ERROR: ./build/kernel_131 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_131.csv" \
        ./build/kernel_131 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 132 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_132" ]; then
        echo "ERROR: ./build/kernel_132 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_132.csv" \
        ./build/kernel_132 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 133 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_133" ]; then
        echo "ERROR: ./build/kernel_133 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_133.csv" \
        ./build/kernel_133 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 134 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_134" ]; then
        echo "ERROR: ./build/kernel_134 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_134.csv" \
        ./build/kernel_134 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 135 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_135" ]; then
        echo "ERROR: ./build/kernel_135 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_135.csv" \
        ./build/kernel_135 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 136 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_136" ]; then
        echo "ERROR: ./build/kernel_136 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_136.csv" \
        ./build/kernel_136 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 137 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_137" ]; then
        echo "ERROR: ./build/kernel_137 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_137.csv" \
        ./build/kernel_137 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 138 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_138" ]; then
        echo "ERROR: ./build/kernel_138 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_138.csv" \
        ./build/kernel_138 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 139 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_139" ]; then
        echo "ERROR: ./build/kernel_139 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_139.csv" \
        ./build/kernel_139 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 140 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_140" ]; then
        echo "ERROR: ./build/kernel_140 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_140.csv" \
        ./build/kernel_140 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 141 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_141" ]; then
        echo "ERROR: ./build/kernel_141 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_141.csv" \
        ./build/kernel_141 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 142 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_142" ]; then
        echo "ERROR: ./build/kernel_142 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_142.csv" \
        ./build/kernel_142 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 143 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_143" ]; then
        echo "ERROR: ./build/kernel_143 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_143.csv" \
        ./build/kernel_143 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 144 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_144" ]; then
        echo "ERROR: ./build/kernel_144 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_144.csv" \
        ./build/kernel_144 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 145 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_145" ]; then
        echo "ERROR: ./build/kernel_145 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_145.csv" \
        ./build/kernel_145 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 146 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_146" ]; then
        echo "ERROR: ./build/kernel_146 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_146.csv" \
        ./build/kernel_146 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 147 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_147" ]; then
        echo "ERROR: ./build/kernel_147 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_147.csv" \
        ./build/kernel_147 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 148 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_148" ]; then
        echo "ERROR: ./build/kernel_148 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_148.csv" \
        ./build/kernel_148 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 149 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_149" ]; then
        echo "ERROR: ./build/kernel_149 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_149.csv" \
        ./build/kernel_149 \
        1 28 28 128 128 3 3 1 1


    echo "Profiling config 150 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_150" ]; then
        echo "ERROR: ./build/kernel_150 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_150.csv" \
        ./build/kernel_150 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 151 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_151" ]; then
        echo "ERROR: ./build/kernel_151 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_151.csv" \
        ./build/kernel_151 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 152 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_152" ]; then
        echo "ERROR: ./build/kernel_152 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_152.csv" \
        ./build/kernel_152 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 153 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_153" ]; then
        echo "ERROR: ./build/kernel_153 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_153.csv" \
        ./build/kernel_153 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 154 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_154" ]; then
        echo "ERROR: ./build/kernel_154 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_154.csv" \
        ./build/kernel_154 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 155 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_155" ]; then
        echo "ERROR: ./build/kernel_155 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_155.csv" \
        ./build/kernel_155 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 156 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_156" ]; then
        echo "ERROR: ./build/kernel_156 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_156.csv" \
        ./build/kernel_156 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 157 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_157" ]; then
        echo "ERROR: ./build/kernel_157 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_157.csv" \
        ./build/kernel_157 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 158 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_158" ]; then
        echo "ERROR: ./build/kernel_158 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_158.csv" \
        ./build/kernel_158 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 159 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_159" ]; then
        echo "ERROR: ./build/kernel_159 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_159.csv" \
        ./build/kernel_159 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 160 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_160" ]; then
        echo "ERROR: ./build/kernel_160 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_160.csv" \
        ./build/kernel_160 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 161 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_161" ]; then
        echo "ERROR: ./build/kernel_161 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_161.csv" \
        ./build/kernel_161 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 162 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_162" ]; then
        echo "ERROR: ./build/kernel_162 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_162.csv" \
        ./build/kernel_162 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 163 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_163" ]; then
        echo "ERROR: ./build/kernel_163 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_163.csv" \
        ./build/kernel_163 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 164 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_164" ]; then
        echo "ERROR: ./build/kernel_164 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_164.csv" \
        ./build/kernel_164 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 165 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_165" ]; then
        echo "ERROR: ./build/kernel_165 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_165.csv" \
        ./build/kernel_165 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 166 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_166" ]; then
        echo "ERROR: ./build/kernel_166 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_166.csv" \
        ./build/kernel_166 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 167 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_167" ]; then
        echo "ERROR: ./build/kernel_167 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_167.csv" \
        ./build/kernel_167 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 168 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_168" ]; then
        echo "ERROR: ./build/kernel_168 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_168.csv" \
        ./build/kernel_168 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 169 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_169" ]; then
        echo "ERROR: ./build/kernel_169 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_169.csv" \
        ./build/kernel_169 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 170 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_170" ]; then
        echo "ERROR: ./build/kernel_170 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_170.csv" \
        ./build/kernel_170 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 171 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_171" ]; then
        echo "ERROR: ./build/kernel_171 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_171.csv" \
        ./build/kernel_171 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 172 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_172" ]; then
        echo "ERROR: ./build/kernel_172 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_172.csv" \
        ./build/kernel_172 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 173 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_173" ]; then
        echo "ERROR: ./build/kernel_173 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_173.csv" \
        ./build/kernel_173 \
        1 14 14 256 256 3 3 1 1


    echo "Profiling config 174 at ${POWER_CAP}W..."

    # Check if executable exists
    if [ ! -f "./build/kernel_174" ]; then
        echo "ERROR: ./build/kernel_174 not found. Please run build.sh first."
        exit 1
    fi

    ncu --target-processes all \
        --set full \
        --print-details all \
        --csv \
        --log-file "$OUTPUT_DIR/ncu_config_174.csv" \
        ./build/kernel_174 \
        1 14 14 256 256 3 3 1 1


    echo ""
    echo "Completed profiling at ${POWER_CAP}W"
    echo "Results saved to: $OUTPUT_DIR/"
    echo ""
done

echo ""
echo "======================================"
echo "All profiling completed!"
echo "======================================"
echo "Total configurations: 175"
echo "Total power cap settings: 5"
echo "Total profiling runs: 875"
echo ""
echo "Results organized in:"
for PC_IDX in {1..5}; do
    echo "  - ncu_results/powercap${PC_IDX}/ (${POWER_CAPS[$((PC_IDX-1))]}W)"
done
echo ""
