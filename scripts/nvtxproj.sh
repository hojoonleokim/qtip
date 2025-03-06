#!/bin/bash

# Process Llama-3.1-8b-Instruct.2.1mad
nsys stats \
    --force-overwrite=true \
    --force-export=true \
    --output=. \
    --format=csv \
    --timeunit=msec \
    --report=nvtx_gpu_proj_sum \
    ./profile_results/Llama-3.1-8b-Instruct.2.1mad.nsys-rep

# Process 3inst
nsys stats \
    --force-overwrite=true \
    --force-export=true \
    --output=. \
    --format=csv \
    --timeunit=msec \
    --report=nvtx_gpu_proj_sum \
    ./profile_results/Llama-3.1-8b-Instruct.2.3inst.nsys-rep

# Process lut
nsys stats \
    --force-overwrite=true \
    --force-export=true \
    --output=. \
    --format=csv \
    --timeunit=msec \
    --report=nvtx_gpu_proj_sum \
    ./profile_results/Llama-3.1-8b-Instruct.2.lut.nsys-rep

# Process quantlut_sym
nsys stats \
    --force-overwrite=true \
    --force-export=true \
    --output=. \
    --format=csv \
    --timeunit=msec \
    --report=nvtx_gpu_proj_sum \
    ./profile_results/Llama-3.1-8b-Instruct.2.quantlut_sym.nsys-rep
