#!/bin/bash

# Get the absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the project base directory
BASE_DIR="$SCRIPT_DIR/.."

RESULT_DIR="$BASE_DIR/profile_results"
mkdir -p "$RESULT_DIR"

# FIXME
MODEL="Llama-3.1-8b-Instruct"
BIT="2"

# Array of decode modes
DECODE_MODES=("quantlut_sym" "1mad" "3inst" "lut")

# Run for each decode mode
for DECODE in "${DECODE_MODES[@]}"; do
    echo "Running profiling for decode mode: $DECODE"
    RESULT_FILE="$MODEL.$BIT.$DECODE.nsys-rep"
    
    # Set the appropriate HF path based on decode mode
    HF_PATH="QTIP_HF/${BIT}bit_${DECODE}/"
    RUN_CMD="python -m eval.eval_ppl --hf_path $HF_PATH"
    
    echo "Using HF path: $HF_PATH"
    echo "Result will be saved to: $RESULT_DIR/$RESULT_FILE"
    
    nsys profile --capture-range=cudaProfilerApi \
        --output="$RESULT_DIR/$RESULT_FILE" \
        --force-overwrite=true \
        ${RUN_CMD}
        
    echo "Completed profiling for $DECODE"
    echo "----------------------------------------"
done
