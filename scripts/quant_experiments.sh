#!/bin/bash

# Configuration paths - Fill these in with your paths
CKPT="QTIP_CKPT"  # Checkpoint directory
HF="QTIP_HF"    # Hugging Face directory
LOG="QTIP_LOG"   # Log directory
HESS="../../Llama-3.1-8B-Hessians"  # Hessian directory

# Create necessary directories
mkdir -p $CKPT $LOG $HF

# Common parameters
BASE_MODEL="meta-llama/Llama-3.1-8B-Instruct"
TD_X=16
TD_Y=16
L=16

# Arrays for different configurations
BITWIDTHS=(2 3 4)
DECODE_MODES=("quantlut_sym" "1mad" "3inst" "lut")

# Function to run training and convert to HF
run_experiment() {
    local bits=$1
    local decode_mode=$2
    
    echo "Starting experiment with ${bits} bits and decode_mode: ${decode_mode}"
    
    # Set V and L based on decode_mode
    if [ "$decode_mode" = "quantlut_sym" ]; then
        V=2
        local effective_L=9
    else
        V=1
        if [ "$decode_mode" = "lut" ]; then
            local effective_L=$L
        else
            local effective_L=1
        fi
    fi
    
    # Create specific output directories
    OUT_DIR="${CKPT}/${bits}bit_${decode_mode}"
    LOG_FILE="${LOG}/${bits}bit_${decode_mode}.log"
    HF_DIR="${HF}/${bits}bit_${decode_mode}"
    
    echo "Step 1: Quantization and Training"
    python -m quantize_llama.quantize_finetune_llama \
        --save_path $OUT_DIR \
        --codebook bitshift \
        --base_model $BASE_MODEL \
        --in_hess_path $HESS \
        --scale_override 0.9 \
        --ft_epochs 5 \
        --td_x $TD_X \
        --td_y $TD_Y \
        --L $L \
        --K $bits \
        --V $V \
        --decode_mode $decode_mode \
        --tlut_bits $effective_L \
        >> $LOG_FILE 2>&1
    
    echo "Step 2: Converting to HuggingFace format"
    python -m quantize_llama.hfize_llama \
        --quantized_path $OUT_DIR \
        --hf_output_path $HF_DIR \
        >> $LOG_FILE 2>&1
    
    echo "Step 3: Finetuning the model"
    python -m quantize_llama.finetune_e2e_llama \
        --base_model $BASE_MODEL \
        --hf_path $HF_DIR \
        --devset_size 640 \
        --ft_valid_size 128 \
        --ft_epochs 4 \
        --ft_update_freq 4 \
        --ft_bs 2 \
        --ctx_size 4096 \
        --ft_train_lut \
        --hf_output_path $HF_DIR \
        >> $LOG_FILE 2>&1
    
    echo "Completed experiment for ${bits} bits and decode_mode: ${decode_mode}"
}

# Main execution loop
for bits in "${BITWIDTHS[@]}"; do
    for decode_mode in "${DECODE_MODES[@]}"; do
        run_experiment $bits $decode_mode
    done
done
