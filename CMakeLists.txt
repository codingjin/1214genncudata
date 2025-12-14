cmake_minimum_required(VERSION 3.18)

# CUDA architecture configuration
# IMPORTANT: Must be set BEFORE project() call
# Can be overridden with: cmake -DCUDA_ARCH=86 ..
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    if(DEFINED CUDA_ARCH)
        # User-specified architecture
        set(CMAKE_CUDA_ARCHITECTURES ${CUDA_ARCH})
    else()
        # Auto-detect: Use nvidia-smi to query GPU compute capability
        execute_process(
            COMMAND nvidia-smi --query-gpu=compute_cap --format=csv,noheader
            OUTPUT_VARIABLE GPU_ARCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        if(GPU_ARCH)
            # Remove decimal point from "8.6" -> "86"
            string(REPLACE "." "" GPU_ARCH_CLEAN "${GPU_ARCH}")
            set(CMAKE_CUDA_ARCHITECTURES ${GPU_ARCH_CLEAN})
        else()
            # Fallback to common architectures if detection fails
            set(CMAKE_CUDA_ARCHITECTURES "70;75;80;86;89;90")
        endif()
    endif()
endif()

project(tvm-dump LANGUAGES C CXX CUDA)

# Print detected/configured architecture
if(DEFINED CUDA_ARCH)
    message(STATUS "CUDA architecture: ${CMAKE_CUDA_ARCHITECTURES} (user-specified)")
else()
    message(STATUS "CUDA architecture: ${CMAKE_CUDA_ARCHITECTURES} (auto-detected)")
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CUDA_STANDARD 11)
set(CMAKE_CUDA_SEPARABLE_COMPILATION OFF)
find_package(OpenMP REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}  ${CUDAPROBLEMSIZE} ${CUDATUNINGP} ${PROGFLAG} -march=native -fopenmp")
#-maxrregcount 128
set(CMAKE_CUDA_FLAGS "-O3 -res-usage -lineinfo  -Xcompiler  \"${CMAKE_CXX_FLAGS}\"")

# Configuration index passed from command line
if(NOT DEFINED CONFIG_IDX)
    set(CONFIG_IDX 0)
endif()

# add_executable for specific configuration
add_executable(kernel_${CONFIG_IDX} kernel/kernel${CONFIG_IDX}.cu template/main.cpp)
