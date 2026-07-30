#!/bin/bash

echo "=== Checking Python versions ==="
PY10=$(which python3.10)
PY12=$(which python3.12)

if [ -n "$PY10" ]; then
    PY=$PY10
    echo "Using Python 3.10"
elif [ -n "$PY12" ]; then
    PY=$PY12
    echo "Using Python 3.12"
else
    echo "ERROR: Python 3.10 or 3.12 not installed."
    echo "Install Python 3.10:"
    echo "  sudo apt install python3.10 python3.10-venv"
    exit 1
fi

echo "=== Creating clean venv ==="
rm -rf venv_fixed
$PY -m venv venv_fixed

echo "=== Activating venv ==="
source venv_fixed/bin/activate

echo "=== Installing PyTorch ROCm ==="
pip install torch==2.10.0+rocm7.2.1 --index-url https://download.pytorch.org/whl/rocm7.2

echo "=== Installing ComfyUI requirements ==="
pip install -r requirements.txt

echo "=== Setting GPU environment variables ==="
export HSA_ENABLE_SDMA=0
export HSA_TOOLS_DISABLE_REGISTER=1
export HSA_OVERRIDE_GFX_VERSION=10.3.0
export HIP_LAUNCH_BLOCKING=1
export AMD_SERIALIZE_KERNEL=3
export PYTORCH_ROCM_ARCH=gfx1031
export CUDA_VISIBLE_DEVICES=0
export TORCH_HIP_ALLOC_CONF=garbage_collection_threshold:0.9,max_split_size_mb:512
export PYTORCH_HIP_ALLOCATOR=naive

echo "=== Running GPU test ==="
python3 - << 'PYEOF'
import torch

print("Torch:", torch.__version__)
print("HIP:", torch.version.hip)
print("CUDA available:", torch.cuda.is_available())

try:
    x = torch.randn(1024,1024, device="cuda")
    y = x @ x
    print("SUM:", y.sum())
except Exception as e:
    print("ERROR:", e)
PYEOF

echo "=== DONE ==="
echo "To run ComfyUI:"
echo "source ~/ComfyUI/venv_fixed/bin/activate"
echo "python3 main.py"
