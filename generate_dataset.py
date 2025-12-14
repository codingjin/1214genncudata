#!/usr/bin/env python3
"""
Generate dataset.csv from all NCU profiling results in ncu_results/ folder.
Uses the metric extraction logic from extract_ncu_metrics.py.
"""
import os
import csv
import re
from pathlib import Path
from extract_ncu_metrics import extract_and_transform_metrics

# Output CSV file
OUTPUT_FILE = "dataset.csv"

# NCU results directory
NCU_RESULTS_DIR = "ncu_results"

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
    "branchefficiency"
]


def extract_config_id(filename):
    """
    Extract the configuration index from filename like 'ncu_config_123.csv'
    Returns the index as an integer, or None if pattern doesn't match.
    """
    match = re.search(r'ncu_config_(\d+)\.csv', filename)
    if match:
        return int(match.group(1))
    return None


def collect_ncu_files(directory):
    """
    Scan the directory for all ncu_config_*.csv files.
    Returns a sorted list of (idx, filepath) tuples.
    """
    results = []

    if not os.path.isdir(directory):
        print(f"Warning: Directory '{directory}' does not exist.")
        return results

    for filename in os.listdir(directory):
        if filename.startswith("ncu_config_") and filename.endswith(".csv"):
            idx = extract_config_id(filename)
            if idx is not None:
                filepath = os.path.join(directory, filename)
                results.append((idx, filepath))

    # Sort by index to maintain order
    results.sort(key=lambda x: x[0])
    return results


def generate_dataset(output_file=OUTPUT_FILE, ncu_dir=NCU_RESULTS_DIR):
    """
    Generate dataset.csv from all NCU CSV files in the specified directory.
    """
    # Collect all NCU files
    ncu_files = collect_ncu_files(ncu_dir)

    if not ncu_files:
        print(f"No NCU config files found in '{ncu_dir}'")
        return

    print(f"Found {len(ncu_files)} NCU configuration file(s)")

    # Open output CSV file
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)

        # Write header
        header = ["id"] + FEATURE_COLUMNS
        writer.writerow(header)

        # Process each NCU file
        for idx, filepath in ncu_files:
            print(f"Processing: {os.path.basename(filepath)} (id={idx})")

            # Extract metrics
            metrics = extract_and_transform_metrics(filepath)

            # Build row: [id, feature1, feature2, ...]
            row = [idx]
            for feature_name in FEATURE_COLUMNS:
                value = metrics.get(feature_name)
                row.append(value)

            # Write row
            writer.writerow(row)

    print(f"\nDataset generated: {output_file}")
    print(f"Total rows: {len(ncu_files)} (+ 1 header)")


def main():
    generate_dataset()


if __name__ == "__main__":
    main()
