#!/usr/bin/env python3
"""
All-in-one pipeline script that:
0. (Optional) Configure GPU for optimal profiling
1. Generates CUDA kernels from TVM sketch configurations
2. Builds all kernel configurations
3. Profiles all kernels with NCU (with optional power cap setting)
4. Generates dataset.csv from NCU profiling results
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


def check_sudo():
    """Check if script is running with sudo privileges."""
    return os.geteuid() == 0


def main():
    parser = argparse.ArgumentParser(
        description='Run complete pipeline: GPU setup → kernel generation → profiling → dataset creation'
    )
    parser.add_argument(
        '--log-file', '-f',
        type=str,
        default='allkernels.json',
        help='Path to the sketch JSON file (default: allkernels.json)'
    )
    parser.add_argument(
        '--setup-gpu',
        action='store_true',
        help='Run GPU setup before pipeline (requires sudo, configures GPU 0, persistent mode, max power)'
    )
    parser.add_argument(
        '--skip-genkernel',
        action='store_true',
        help='Skip kernel generation step (use existing kernel/ files)'
    )
    parser.add_argument(
        '--skip-build',
        action='store_true',
        help='Skip build step (use existing build/kernel_* executables)'
    )
    parser.add_argument(
        '--skip-profiling',
        action='store_true',
        help='Skip profiling step (use existing ncu_results/ files)'
    )
    parser.add_argument(
        '--power-cap',
        type=str,
        default=None,
        help='Set GPU 0 power cap for profiling (in watts, or "max" for maximum). Example: --power-cap 300'
    )

    args = parser.parse_args()

    # Check sudo requirement for GPU setup
    if args.setup_gpu and not check_sudo():
        print("\n✗ ERROR: --setup-gpu requires sudo privileges")
        print("Please run: sudo python run_pipeline.py --setup-gpu")
        sys.exit(1)

    print("="*60)
    print("TVM Kernel Pipeline - Complete Workflow")
    print("="*60)
    print(f"GPU setup: {args.setup_gpu}")
    print(f"Sketch file: {args.log_file}")
    print(f"Skip kernel generation: {args.skip_genkernel}")
    print(f"Skip build: {args.skip_build}")
    print(f"Skip profiling: {args.skip_profiling}")
    if args.power_cap:
        print(f"Power cap: {args.power_cap}W")
    print("="*60)

    # Step 0: GPU Setup (optional)
    if args.setup_gpu:
        setup_script = os.path.join(os.path.dirname(__file__), 'setup_gpu.sh')
        if not os.path.exists(setup_script):
            print(f"\n✗ ERROR: setup_gpu.sh not found at {setup_script}")
            sys.exit(1)

        run_command(
            ['bash', setup_script],
            "Configuring GPU for optimal profiling (passwordless nvidia-smi, single GPU, persistent mode, max power)"
        )
    else:
        print("\n⊘ Skipping GPU setup (use --setup-gpu to configure)")

    # Step 1: Generate CUDA kernels from TVM sketches
    if not args.skip_genkernel:
        run_command(
            ['python', 'genkernel.py', '-f', args.log_file],
            f"Generating CUDA kernels from {args.log_file}"
        )
    else:
        print("\n⊘ Skipping kernel generation (--skip-genkernel)")

    # Step 2: Build all kernels
    if not args.skip_build:
        if not os.path.exists('build.sh'):
            print("\n✗ ERROR: build.sh not found!")
            print("Please run genkernel.py first to generate build.sh")
            sys.exit(1)

        run_command(
            'bash build.sh',
            "Building all kernel configurations",
            shell=True
        )
    else:
        print("\n⊘ Skipping build (--skip-build)")

    # Step 3: Profile all kernels with NCU
    if not args.skip_profiling:
        if not os.path.exists('profile.sh'):
            print("\n✗ ERROR: profile.sh not found!")
            print("Please run genkernel.py first to generate profile.sh")
            sys.exit(1)

        # Build profiling command with optional power cap
        if args.power_cap:
            profile_cmd = f'bash profile.sh {args.power_cap}'
            description = f"Profiling all kernels with NCU (power cap: {args.power_cap}W)"
        else:
            profile_cmd = 'bash profile.sh'
            description = "Profiling all kernels with NCU"

        run_command(profile_cmd, description, shell=True)
    else:
        print("\n⊘ Skipping profiling (--skip-profiling)")

    # Step 4: Generate dataset.csv from NCU results
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
    print("  - build.sh (build script)")
    print("  - profile.sh (profiling script with power cap support)")
    print("  - build/kernel_* (compiled executables)")
    print("  - ncu_results/ncu_config_*.csv (NCU profiling results)")
    print("  - dataset.csv (XGBoost-ready feature dataset)")
    print(f"\nDataset is ready for training at: {os.path.abspath('dataset.csv')}")
    print(f"\nTo re-profile with different power settings:")
    print(f"  bash profile.sh 250    # Profile at 250W")
    print(f"  bash profile.sh max    # Profile at maximum power")


if __name__ == "__main__":
    main()
