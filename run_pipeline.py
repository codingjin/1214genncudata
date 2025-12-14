#!/usr/bin/env python3
"""
All-in-one pipeline script that:
1. Generates CUDA kernels from TVM sketch configurations
2. Builds and profiles all kernels with NCU
3. Generates dataset.csv from NCU profiling results
"""
import subprocess
import sys
import argparse
import os


def run_command(cmd, description, shell=False):
    """
    Execute a command and handle errors.

    Args:
        cmd: Command to execute (list or string)
        description: Human-readable description of what the command does
        shell: Whether to run command through shell
    """
    print(f"\n{'='*60}")
    print(f"Step: {description}")
    print(f"{'='*60}")

    try:
        if shell:
            result = subprocess.run(cmd, shell=True, check=True, text=True)
        else:
            result = subprocess.run(cmd, check=True, text=True)

        print(f"✓ {description} completed successfully")
        return result

    except subprocess.CalledProcessError as e:
        print(f"\n✗ ERROR: {description} failed!")
        print(f"Exit code: {e.returncode}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Run complete pipeline: kernel generation → profiling → dataset creation'
    )
    parser.add_argument(
        '--log-file', '-f',
        type=str,
        default='allkernels.json',
        help='Path to the sketch JSON file (default: allkernels.json)'
    )
    parser.add_argument(
        '--skip-genkernel',
        action='store_true',
        help='Skip kernel generation step (use existing kernel/ files)'
    )
    parser.add_argument(
        '--skip-profiling',
        action='store_true',
        help='Skip profiling step (use existing ncu_results/ files)'
    )

    args = parser.parse_args()

    print("="*60)
    print("TVM Kernel Pipeline - Complete Workflow")
    print("="*60)
    print(f"Sketch file: {args.log_file}")
    print(f"Skip kernel generation: {args.skip_genkernel}")
    print(f"Skip profiling: {args.skip_profiling}")
    print("="*60)

    # Step 1: Generate CUDA kernels from TVM sketches
    if not args.skip_genkernel:
        run_command(
            ['python', 'genkernel.py', '-f', args.log_file],
            f"Generating CUDA kernels from {args.log_file}"
        )
    else:
        print("\n⊘ Skipping kernel generation (--skip-genkernel)")

    # Step 2: Build and profile all kernels with NCU
    if not args.skip_profiling:
        if not os.path.exists('run.sh'):
            print("\n✗ ERROR: run.sh not found!")
            print("Please run genkernel.py first to generate run.sh")
            sys.exit(1)

        run_command(
            'bash run.sh',
            "Building and profiling all kernels with NCU",
            shell=True
        )
    else:
        print("\n⊘ Skipping profiling (--skip-profiling)")

    # Step 3: Generate dataset.csv from NCU results
    run_command(
        ['python', 'generate_dataset.py'],
        "Generating dataset.csv from NCU results"
    )

    # Final summary
    print(f"\n{'='*60}")
    print("Pipeline completed successfully!")
    print(f"{'='*60}")
    print("\nGenerated files:")
    print("  - kernel/kernel*.cuh (CUDA kernel headers)")
    print("  - kernel/kernel*.cu (CUDA kernel wrappers)")
    print("  - ncu_results/ncu_config_*.csv (NCU profiling results)")
    print("  - dataset.csv (XGBoost-ready feature dataset)")
    print(f"\nDataset is ready for training at: {os.path.abspath('dataset.csv')}")


if __name__ == "__main__":
    main()
