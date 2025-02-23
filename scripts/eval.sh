#!/bin/bash

# FIXME
MODEL="Llama-3.1-8b-Instruct"
# Array of bits to evaluate
BITS=("3" "4")

# Array of decode modes
DECODE_MODES=("quantlut_sym" "1mad" "3inst" "lut")

# Run for each bit
for BIT in "${BITS[@]}"; do
    echo "Starting evaluation for ${BIT}-bit quantization"
    echo "=============================================="

    # Run for each decode mode
    for DECODE in "${DECODE_MODES[@]}"; do
        echo "Running profiling for decode mode: $DECODE"

        # Set the appropriate HF path based on decode mode
        HF_PATH="QTIP_HF/${BIT}bit_${DECODE}/"
        python -m eval.eval_ppl --hf_path $HF_PATH
        
        echo "Completed profiling for $DECODE"
        echo "----------------------------------------"
    done

    echo "Completed evaluation for ${BIT}-bit quantization"
    echo "=============================================="
    echo
done
