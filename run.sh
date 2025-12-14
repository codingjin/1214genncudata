#!/bin/bash
# Auto-generated run script for all sketch configurations
# Total configurations: 3

mkdir -p build
mkdir -p ncu_results


echo ""
echo "======================================"
echo "Configuration 0"
echo "Parameters: N=1 H=14 W=14 CO=256 CI=256 KH=3 KW=3"
echo "Grid: 14, Block: 448"
echo "======================================"

echo "Building configuration 0..."
cd build
cmake -DCONFIG_IDX=0 ..
make -j
cd ..

echo "Profiling configuration 0..."
ncu --target-processes all \
    --set full \
    --print-details all \
    --csv \
    --log-file ncu_results/ncu_config_0.csv \
    ./build/kernel_0 \
    1 14 14 256 256 3 3 1 1


echo ""
echo "======================================"
echo "Configuration 1"
echo "Parameters: N=1 H=224 W=224 CO=64 CI=3 KH=7 KW=7"
echo "Grid: 224, Block: 224"
echo "======================================"

echo "Building configuration 1..."
cd build
cmake -DCONFIG_IDX=1 ..
make -j
cd ..

echo "Profiling configuration 1..."
ncu --target-processes all \
    --set full \
    --print-details all \
    --csv \
    --log-file ncu_results/ncu_config_1.csv \
    ./build/kernel_1 \
    1 224 224 64 3 7 7 2 3


echo ""
echo "======================================"
echo "Configuration 2"
echo "Parameters: N=1 H=272 W=272 CO=64 CI=32 KH=3 KW=3"
echo "Grid: 68, Block: 272"
echo "======================================"

echo "Building configuration 2..."
cd build
cmake -DCONFIG_IDX=2 ..
make -j
cd ..

echo "Profiling configuration 2..."
ncu --target-processes all \
    --set full \
    --print-details all \
    --csv \
    --log-file ncu_results/ncu_config_2.csv \
    ./build/kernel_2 \
    1 272 272 64 32 3 3 1 1


echo ""
echo "======================================"
echo "All profiling completed!"
echo "Results saved to ncu_results/ncu_config_*.csv"
echo "======================================"
