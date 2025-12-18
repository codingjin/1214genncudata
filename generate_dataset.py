#!/usr/bin/env python3
"""
Generate dataset_feature.csv from all NCU profiling results in ncu_results/ folder.
Scans all powercap subdirectories (powercap1-3 for A30, powercap1-5 for other GPUs).
Includes power cap information with automatic GPU detection.
Uses the metric extraction logic from extract_ncu_metrics.py.
"""
import os
import csv
import re
import subprocess
from pathlib import Path
from extract_ncu_metrics import extract_and_transform_metrics

# Output CSV file
OUTPUT_FILE = "dataset_feature.csv"

# NCU results directory
NCU_RESULTS_DIR = "ncu_results"

# Power cap settings for different GPU types
# Note: A30 has 3 settings, others have 5 settings
POWER_CAP_CONFIGS = {
    "RTX 3090": [100, 200, 300, 400, 450],
    "RTX 4090": [150, 200, 300, 400, 450],
    "A30": [100, 130, 165],
    "V100": [100, 150, 200, 250, 300],
    "A100": [100, 200, 250, 300, 400],
}

# Column order (must match the feature names from extract_ncu_metrics.py)
FEATURE_COLUMNS = [
    "blocksize(k)",
    "threads(k)",
    "reg_thread(k)",
    "shm_block(mb)",
    "occupancy",
    "mem",
    "compute",
    "time(ms)",
    "global_load(m)",
    "global_store(m)",
    "shm_load(m)",
    "shm_store(m)",
    "inst(m)",
    "sm_freq(ghz)",
    "mem_freq(ghz)"
]


def detect_gpu_type():
    """
    Detect the GPU type using nvidia-smi.
    Returns the GPU type string that matches POWER_CAP_CONFIGS keys.
    """
    try:
        result = subprocess.run(
            ["nvidia-smi", "--query-gpu=name", "--format=csv,noheader", "-i", "0"],
            capture_output=True,
            text=True,
            check=True
        )
        gpu_name = result.stdout.strip()

        # Match against known GPU types
        for gpu_type in POWER_CAP_CONFIGS.keys():
            if gpu_type in gpu_name:
                return gpu_type

        print(f"Warning: Unknown GPU '{gpu_name}'. Cannot determine power cap values.")
        return None
    except Exception as e:
        print(f"Warning: Could not detect GPU type: {e}")
        return None


def extract_config_id(filename):
    """
    Extract the configuration index from filename like 'ncu_config_123.csv'
    Returns the index as an integer, or None if pattern doesn't match.
    """
    match = re.search(r'ncu_config_(\d+)\.csv', filename)
    if match:
        return int(match.group(1))
    return None


def extract_powercap_idx(dirname):
    """
    Extract the power cap index from directory name like 'powercap1'
    Returns the index as an integer (1-based index), or None if pattern doesn't match.
    Note: A30 has indices 1-3, other GPUs have indices 1-5.
    """
    match = re.search(r'powercap(\d+)', dirname)
    if match:
        return int(match.group(1))
    return None


def collect_ncu_files(directory):
    """
    Scan the directory for all ncu_config_*.csv files in powercap subdirectories.
    Returns a sorted list of (config_idx, powercap_idx, filepath) tuples.
    Sorted by (config_idx, powercap_idx) for proper sequential ID assignment.
    """
    results = []

    if not os.path.isdir(directory):
        print(f"Warning: Directory '{directory}' does not exist.")
        return results

    # Scan for powercap subdirectories
    for subdir_name in os.listdir(directory):
        subdir_path = os.path.join(directory, subdir_name)

        # Check if it's a powercap directory
        if os.path.isdir(subdir_path) and subdir_name.startswith("powercap"):
            powercap_idx = extract_powercap_idx(subdir_name)
            if powercap_idx is None:
                continue

            # Scan for NCU CSV files in this subdirectory
            for filename in os.listdir(subdir_path):
                if filename.startswith("ncu_config_") and filename.endswith(".csv"):
                    config_idx = extract_config_id(filename)
                    if config_idx is not None:
                        filepath = os.path.join(subdir_path, filename)
                        results.append((config_idx, powercap_idx, filepath))

    # Sort by (config_idx, powercap_idx) to maintain order:
    # config_0 at all powercaps, then config_1 at all powercaps, etc.
    results.sort(key=lambda x: (x[0], x[1]))
    return results


def generate_dataset(output_file=OUTPUT_FILE, ncu_dir=NCU_RESULTS_DIR):
    """
    Generate dataset_feature.csv from all NCU CSV files in powercap subdirectories.
    Includes power cap index and wattage for each configuration.
    """
    # Detect GPU type to get power cap values
    gpu_type = detect_gpu_type()
    if gpu_type:
        power_caps = POWER_CAP_CONFIGS[gpu_type]
        # Format GPU name without spaces for dataset (e.g., "RTX 3090" -> "RTX3090")
        gpu_name = gpu_type.replace(" ", "")
        print(f"Detected GPU: {gpu_type}")
        print(f"GPU name for dataset: {gpu_name}")
        print(f"Power cap settings: {power_caps} W")
    else:
        print("Warning: Could not detect GPU type. GPU name and power cap wattage will be set to None.")
        gpu_name = None
        power_caps = [None, None, None, None, None]

    print()

    # Collect all NCU files from powercap subdirectories
    ncu_files = collect_ncu_files(ncu_dir)

    if not ncu_files:
        print(f"No NCU config files found in '{ncu_dir}/powercap*/' subdirectories")
        return

    print(f"Found {len(ncu_files)} NCU profiling result(s)")
    print()

    # Open output CSV file
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)

        # Write header: [id, gpu, powercap(w), features...]
        header = ["id", "gpu", "powercap(w)"] + FEATURE_COLUMNS
        writer.writerow(header)

        # Process each NCU file with sequential ID
        sequential_id = 1
        for config_idx, powercap_idx, filepath in ncu_files:
            # Get actual power cap wattage with bounds checking
            # (A30 has 3 settings, other GPUs have 5 settings)
            if gpu_type and powercap_idx - 1 < len(power_caps):
                powercap_watts = power_caps[powercap_idx - 1]
            else:
                powercap_watts = None
                if gpu_type:
                    print(f"Warning: powercap index {powercap_idx} out of range for {gpu_type} "
                          f"(only {len(power_caps)} power cap settings configured)")

            print(f"Processing: powercap{powercap_idx}/ncu_config_{config_idx}.csv "
                  f"(id={sequential_id}, config={config_idx}, GPU={gpu_name}, powercap={powercap_watts}W)")

            # Extract metrics
            metrics = extract_and_transform_metrics(filepath)

            # Build row: [sequential_id, GPU, powercap_watts, feature1, feature2, ...]
            row = [sequential_id, gpu_name, powercap_watts]
            for feature_name in FEATURE_COLUMNS:
                value = metrics.get(feature_name)
                row.append(value)

            # Write row
            writer.writerow(row)

            # Increment sequential ID
            sequential_id += 1

    print(f"\nDataset generated: {output_file}")
    print(f"Total rows: {len(ncu_files)} (+ 1 header)")
    print(f"Columns: id, GPU, powercap(w), {len(FEATURE_COLUMNS)} features")


def main():
    generate_dataset()


if __name__ == "__main__":
    main()
