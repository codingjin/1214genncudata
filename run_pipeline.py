#!/usr/bin/env python3
"""
All-in-one pipeline script that:
1. Validates GPU setup (persistent mode, power cap, etc.)
2. Generates CUDA kernels from TVM sketch configurations
3. Builds all kernel configurations
4. Profiles all kernels with NCU at 5 different power caps (auto-detected based on GPU type)
5. Generates dataset.csv from NCU profiling results
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


def validate_gpu_setup():
    """
    Validate that GPU has been configured correctly using setup_gpu.sh.
    Checks:
    1. nvidia-smi is accessible (passwordless)
    2. Persistent mode is enabled
    3. For multi-GPU systems, only GPU 0 is enabled
    4. Power cap is set to a reasonable value

    Returns True if all checks pass, False otherwise.
    """
    print("\n" + "="*60)
    print("Validating GPU Setup")
    print("="*60)

    errors = []
    warnings = []

    # Check 1: nvidia-smi is accessible without sudo
    try:
        result = subprocess.run(
            ['nvidia-smi', '--query-gpu=count', '--format=csv,noheader'],
            capture_output=True,
            text=True,
            check=True
        )
        gpu_count = int(result.stdout.strip())
        print(f"✓ nvidia-smi accessible (detected {gpu_count} GPU(s))")
    except subprocess.CalledProcessError:
        errors.append("nvidia-smi command failed. GPU drivers may not be installed.")
        return False, errors, warnings
    except FileNotFoundError:
        errors.append("nvidia-smi not found. Please install NVIDIA drivers.")
        return False, errors, warnings

    # Check 2: Persistent mode enabled for GPU 0
    try:
        result = subprocess.run(
            ['nvidia-smi', '-i', '0', '--query-gpu=persistence_mode', '--format=csv,noheader'],
            capture_output=True,
            text=True,
            check=True
        )
        persistence_mode = result.stdout.strip()
        if persistence_mode == "Enabled":
            print(f"✓ Persistent mode enabled on GPU 0")
        else:
            errors.append(f"Persistent mode is NOT enabled on GPU 0 (current: {persistence_mode})")
    except subprocess.CalledProcessError as e:
        errors.append(f"Failed to query persistent mode: {e}")

    # Check 3: For multi-GPU, check compute mode
    if gpu_count > 1:
        # Check GPU 0 is in Default mode (allows compute)
        try:
            result = subprocess.run(
                ['nvidia-smi', '-i', '0', '--query-gpu=compute_mode', '--format=csv,noheader'],
                capture_output=True,
                text=True,
                check=True
            )
            compute_mode_0 = result.stdout.strip()
            if compute_mode_0 == "Default":
                print(f"✓ GPU 0 compute mode: {compute_mode_0} (enabled)")
            else:
                errors.append(f"GPU 0 compute mode is {compute_mode_0}, should be Default")
        except subprocess.CalledProcessError as e:
            warnings.append(f"Failed to query GPU 0 compute mode: {e}")

        # Check other GPUs are disabled
        for i in range(1, gpu_count):
            try:
                result = subprocess.run(
                    ['nvidia-smi', '-i', str(i), '--query-gpu=compute_mode', '--format=csv,noheader'],
                    capture_output=True,
                    text=True,
                    check=True
                )
                compute_mode = result.stdout.strip()
                if compute_mode == "Prohibited":
                    print(f"✓ GPU {i} compute mode: {compute_mode} (disabled)")
                else:
                    warnings.append(f"GPU {i} compute mode is {compute_mode}, should be Prohibited (disabled)")
            except subprocess.CalledProcessError as e:
                warnings.append(f"Failed to query GPU {i} compute mode: {e}")

    # Check 4: Power cap is reasonable (at least 70% of max)
    try:
        # Get current power limit
        result = subprocess.run(
            ['nvidia-smi', '-i', '0', '--query-gpu=power.limit', '--format=csv,noheader,nounits'],
            capture_output=True,
            text=True,
            check=True
        )
        current_power = float(result.stdout.strip())

        # Get max power limit
        result = subprocess.run(
            ['nvidia-smi', '-i', '0', '--query-gpu=power.max_limit', '--format=csv,noheader,nounits'],
            capture_output=True,
            text=True,
            check=True
        )
        max_power = float(result.stdout.strip())

        power_percentage = (current_power / max_power) * 100

        print(f"✓ GPU 0 power cap: {current_power:.1f}W / {max_power:.1f}W ({power_percentage:.1f}%)")

        if power_percentage < 70:
            warnings.append(f"GPU 0 power cap is only {power_percentage:.1f}% of maximum. Consider increasing for better performance.")
    except subprocess.CalledProcessError as e:
        warnings.append(f"Failed to query power cap: {e}")
    except ValueError as e:
        warnings.append(f"Failed to parse power cap values: {e}")

    return len(errors) == 0, errors, warnings


def main():
    parser = argparse.ArgumentParser(
        description='Run complete pipeline: kernel generation → build → profile → dataset creation'
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
        '--skip-build',
        action='store_true',
        help='Skip build step (use existing build/kernel_* executables)'
    )
    parser.add_argument(
        '--skip-profiling',
        action='store_true',
        help='Skip profiling step (use existing ncu_results/powercap*/ files)'
    )
    parser.add_argument(
        '--skip-gpu-check',
        action='store_true',
        help='Skip GPU setup validation (not recommended)'
    )

    args = parser.parse_args()

    print("="*60)
    print("TVM Kernel Pipeline - Complete Workflow")
    print("="*60)
    print(f"Sketch file: {args.log_file}")
    print(f"Skip kernel generation: {args.skip_genkernel}")
    print(f"Skip build: {args.skip_build}")
    print(f"Skip profiling: {args.skip_profiling}")
    print("Profiling mode: Auto-detect GPU and profile at 5 power caps")
    print("="*60)

    # Validate GPU setup
    if not args.skip_gpu_check:
        valid, errors, warnings = validate_gpu_setup()

        # Display warnings
        if warnings:
            print("\n⚠ WARNINGS:")
            for warning in warnings:
                print(f"  - {warning}")

        # Check for errors
        if not valid:
            print("\n" + "="*60)
            print("✗ GPU SETUP VALIDATION FAILED")
            print("="*60)
            print("\nERRORS detected:")
            for error in errors:
                print(f"  ✗ {error}")
            print("\nPlease run the GPU setup script first:")
            print("  sudo ./setup_gpu.sh")
            print("\nOr skip GPU validation with --skip-gpu-check (not recommended)")
            sys.exit(1)

        print("\n✓ GPU setup validation passed")
    else:
        print("\n⊘ Skipping GPU setup validation (--skip-gpu-check)")

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

    # Step 3: Profile all kernels with NCU at 5 power caps
    if not args.skip_profiling:
        if not os.path.exists('profile.sh'):
            print("\n✗ ERROR: profile.sh not found!")
            print("Please run genkernel.py first to generate profile.sh")
            sys.exit(1)

        run_command(
            'bash profile.sh',
            "Profiling all kernels at 5 power caps (auto-detected GPU type)",
            shell=True
        )
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
    print("  - profile.sh (auto-detects GPU and profiles at 5 power caps)")
    print("  - build/kernel_* (compiled executables)")
    print("  - ncu_results/powercap1-5/ncu_config_*.csv (NCU profiling results)")
    print("  - dataset.csv (XGBoost-ready feature dataset with GPU and power cap info)")
    print(f"\nDataset is ready for training at: {os.path.abspath('dataset.csv')}")
    print(f"\nDataset includes:")
    print(f"  - All kernel configurations × 5 power cap settings")
    print(f"  - GPU type identifier (RTX3090/RTX4090/V100/A30/A100)")
    print(f"  - Power cap wattage for each measurement")
    print(f"  - 16 performance/hardware features")


if __name__ == "__main__":
    main()
