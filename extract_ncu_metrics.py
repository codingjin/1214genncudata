#!/usr/bin/env python3
import csv
import sys

# Mapping from original Nsight Compute metric name
# -> (new feature name, scale_divisor)
METRIC_TRANSFORMS = {
    "Block Size": ("blocksize(k)", 1000.0),
    "Threads": ("threads(k)", 1000.0),
    "Registers Per Thread": ("reg_thread(k)", 1000.0),
    "Static Shared Memory Per Block": ("shm_block(mb)", 1048576.0),  # bytes -> MB
    "Achieved Occupancy": ("occupancy", 100.0),                      # percent -> 0–1
    "Memory [%]": ("mem", 100.0),                                    # percent -> 0–1
    "Compute (SM) [%]": ("compute", 100.0),                          # percent -> 0–1
    "Duration": ("time(ms)", 1_000_000.0),                           # ns -> ms (if Duration is in ns)
    "smsp__sass_inst_executed_op_global_ld.sum": ("global_load(m)", 1_000_000.0),
    "smsp__sass_inst_executed_op_global_st.sum": ("global_store(m)", 1_000_000.0),
    "smsp__sass_inst_executed_op_shared_ld.sum": ("shm_load(m)", 1_000_000.0),
    "smsp__sass_inst_executed_op_shared_st.sum": ("shm_store(m)", 1_000_000.0),

    # NEW ONES:
    # total dynamic instructions, scaled to millions
    "Instructions Executed": ("inst(m)", 1_000_000.0),
    # branch efficiency as 0–1 instead of percent
    "Branch Efficiency": ("branchefficiency", 100.0),
}

WANTED_METRICS = list(METRIC_TRANSFORMS.keys())


def clean_numeric(value_str: str):
    """
    Try to convert a Metric Value like '25,632' or '24.29' into int or float.
    If it fails, return the original string.
    """
    if value_str is None:
        return None

    s = value_str.replace(",", "").strip()
    if not s:
        return value_str

    try:
        return int(s)
    except ValueError:
        try:
            return float(s)
        except ValueError:
            return value_str


def extract_and_transform_metrics(csv_path: str):
    """
    Read an Nsight Compute CSV export, extract the wanted metrics,
    apply unit conversions, and return a dict:
        { new_feature_name: scaled_value, ... }
    """
    raw_results = {name: None for name in WANTED_METRICS}

    with open(csv_path, newline="", encoding="utf-8", errors="ignore") as f:
        # Skip profiler banner lines like "==PROF== ..."
        filtered_lines = (
            line for line in f if not line.lstrip().startswith("==PROF==")
        )

        reader = csv.DictReader(filtered_lines)
        for row in reader:
            name = row.get("Metric Name")
            if name in raw_results and raw_results[name] is None:
                raw_val = row.get("Metric Value")
                raw_results[name] = clean_numeric(raw_val)

    # Apply renaming and scaling
    transformed = {}
    for orig_name, (new_name, divisor) in METRIC_TRANSFORMS.items():
        val = raw_results.get(orig_name)
        if isinstance(val, (int, float)) and divisor not in (0, None):
            transformed[new_name] = val / divisor
        else:
            # If we couldn't parse as number, just keep the raw value
            transformed[new_name] = val

    return transformed


def main():
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <ncu_csv_file>")
        sys.exit(1)

    csv_path = sys.argv[1]
    metrics = extract_and_transform_metrics(csv_path)

    print(f"Transformed metrics from: {csv_path}\n")
    for new_name, value in metrics.items():
        print(f"{new_name}: {value}")


if __name__ == "__main__":
    main()
