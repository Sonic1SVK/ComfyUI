#!/bin/bash

# --- odstránenie Zludy, ak bola nastavená ---
unset LD_PRELOAD
unset ZLUDA_LOG_LEVEL

# --- ROCm / HIP stabilita ---
export HSA_ENABLE_SDMA=0
export HSA_TOOLS_DISABLE_REGISTER=1
export HSA_OVERRIDE_GFX_VERSION=10.3.0

# --- HIP debugging / stabilita ---
export HIP_LAUNCH_BLOCKING=1
export AMD_SERIALIZE_KERNEL=3

# --- PyTorch HIP arch ---
export PYTORCH_ROCM_ARCH=gfx1031

# --- CUDA emulácia pre PyTorch/RVC ---
export CUDA_VISIBLE_DEVICES=0

# --- Allocator fixy pre ComfyUI / veľké modely ---
export TORCH_HIP_ALLOC_CONF=garbage_collection_threshold:0.9,max_split_size_mb:512
export PYTORCH_HIP_ALLOCATOR=naive

echo "GPU environment variables loaded."
