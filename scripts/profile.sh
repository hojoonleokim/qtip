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
DECODE="quantlut_sym"

RESULT_FILE="$MODEL.$BIT.$DECODE.nsys-rep"

RUN_CMD="python -m eval.eval_ppl  --hf_path relaxml/Llama-3.1-8b-Instruct-QTIP-4Bit"
RUN_CMD="python -m eval.eval_ppl  --hf_path QTIP_HF/2bit_quantlut_sym/"

nsys profile --capture-range=cudaProfilerApi \
  --output="$RESULT_DIR/$RESULT_FILE" \
  --force-overwrite=true \
  ${RUN_CMD}



