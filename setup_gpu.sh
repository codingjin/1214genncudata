#!/bin/bash

# GPU Setup Script
# This script configures NVIDIA GPUs for optimal profiling performance:
# 1. Makes nvidia-smi passwordless (adds sudoers rule)
# 2. For multi-GPU systems, enables only GPU 0 and disables others
# 3. Enables persistent mode
# 4. Sets power cap to maximum

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Make nvidia-smi passwordless
setup_passwordless_nvidia_smi() {
    print_info "Setting up passwordless nvidia-smi..."

    local sudoers_file="/etc/sudoers.d/nvidia-smi"
    local username="${SUDO_USER:-$USER}"

    # Create sudoers rule for nvidia-smi commands
    cat > "$sudoers_file" << EOF
# Allow $username to run nvidia-smi commands without password
$username ALL=(ALL) NOPASSWD: /usr/bin/nvidia-smi
$username ALL=(ALL) NOPASSWD: /usr/bin/nvidia-smi *
EOF

    # Set correct permissions for sudoers file
    chmod 0440 "$sudoers_file"

    # Verify the sudoers file is valid
    if visudo -c -f "$sudoers_file" > /dev/null 2>&1; then
        print_success "Passwordless nvidia-smi configured for user: $username"
    else
        print_error "Invalid sudoers file generated, removing..."
        rm -f "$sudoers_file"
        exit 1
    fi
}

# Get GPU count
get_gpu_count() {
    nvidia-smi --query-gpu=count --format=csv,noheader | head -1
}

# Configure multi-GPU setup (enable only GPU 0)
configure_multi_gpu() {
    local gpu_count=$(get_gpu_count)
    print_info "Detected $gpu_count GPU(s)"

    if [ "$gpu_count" -eq 1 ]; then
        print_info "Single GPU system detected, no need to disable other GPUs"
        return
    fi

    print_info "Multi-GPU system detected, configuring GPU 0 as primary..."

    # Enable compute mode for GPU 0 (Default - multiple processes allowed)
    nvidia-smi -i 0 -c 0
    print_success "GPU 0 set to Default compute mode (enabled)"

    # Set other GPUs to prohibited compute mode (disables compute)
    for ((i=1; i<gpu_count; i++)); do
        print_info "Disabling GPU $i..."
        nvidia-smi -i $i -c 2  # 2 = Prohibited (no compute contexts)
        print_success "GPU $i set to Prohibited compute mode (disabled)"
    done

    print_warning "Note: Disabled GPUs can still be seen by nvidia-smi but cannot run CUDA kernels"
    print_warning "To re-enable all GPUs, run: sudo nvidia-smi -c 0 (applies to all GPUs)"
}

# Enable persistent mode
enable_persistent_mode() {
    print_info "Enabling persistent mode..."

    local gpu_count=$(get_gpu_count)

    # Enable persistent mode for all GPUs
    nvidia-smi -pm 1

    if [ $? -eq 0 ]; then
        print_success "Persistent mode enabled for all GPUs"
    else
        print_error "Failed to enable persistent mode"
        exit 1
    fi
}

# Set power cap to maximum
set_max_power_cap() {
    print_info "Setting power cap to maximum..."

    local gpu_count=$(get_gpu_count)

    # Set power cap for GPU 0 (primary GPU)
    local max_power=$(nvidia-smi -i 0 --query-gpu=power.max_limit --format=csv,noheader,nounits | awk '{print int($1)}')

    if [ -z "$max_power" ] || [ "$max_power" -eq 0 ]; then
        print_warning "Could not determine max power limit for GPU 0"
        return
    fi

    print_info "GPU 0 max power limit: ${max_power}W"

    # Set power limit to maximum
    nvidia-smi -i 0 -pl $max_power

    if [ $? -eq 0 ]; then
        print_success "GPU 0 power cap set to ${max_power}W (maximum)"
    else
        print_warning "Failed to set power cap for GPU 0 (may not be supported on this GPU)"
    fi

    # For other GPUs (if any), we can optionally set them too or leave them as is
    # Since we disabled them, we'll just report their max power
    if [ "$gpu_count" -gt 1 ]; then
        print_info "Other GPU power limits (disabled GPUs):"
        for ((i=1; i<gpu_count; i++)); do
            local other_max_power=$(nvidia-smi -i $i --query-gpu=power.max_limit --format=csv,noheader,nounits | awk '{print int($1)}')
            print_info "  GPU $i max power limit: ${other_max_power}W"
        done
    fi
}

# Display current GPU configuration
show_gpu_status() {
    print_info "Current GPU Configuration:"
    echo ""
    nvidia-smi
    echo ""
}

# Main execution
main() {
    echo "=========================================="
    echo "    NVIDIA GPU Setup Configuration"
    echo "=========================================="
    echo ""

    # Check if running as root
    check_root

    # Check if nvidia-smi is available
    if ! command -v nvidia-smi &> /dev/null; then
        print_error "nvidia-smi not found. Please install NVIDIA drivers first."
        exit 1
    fi

    # Execute setup steps
    setup_passwordless_nvidia_smi
    echo ""

    configure_multi_gpu
    echo ""

    enable_persistent_mode
    echo ""

    set_max_power_cap
    echo ""

    # Show final configuration
    show_gpu_status

    print_success "GPU setup completed successfully!"
    echo ""
    print_info "Summary of changes:"
    echo "  ✓ nvidia-smi is now passwordless for user: ${SUDO_USER:-$USER}"
    echo "  ✓ GPU 0 enabled as primary GPU"
    echo "  ✓ Other GPUs (if any) disabled for compute"
    echo "  ✓ Persistent mode enabled"
    echo "  ✓ Power cap set to maximum for GPU 0"
    echo ""
    print_warning "To restore all GPUs to default state, run:"
    echo "  sudo nvidia-smi -c 0    # Enable all GPUs"
    echo "  sudo nvidia-smi -pm 0   # Disable persistent mode"
}

# Run main function
main
