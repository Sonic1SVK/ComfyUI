#!/bin/bash

echo "=== Detecting available Python versions ==="
PY10=$(which python3.10)
PY12=$(which python3.12)

if [ -n "$PY10" ]; then
    PY=$PY10
    echo "Using Python 3.10: $PY"
elif [ -n "$PY12" ]; then
    PY=$PY12
    echo "Using Python 3.12: $PY"
else
    echo "ERROR: Python 3.10 or 3.12 not installed."
    echo "Install Python 3.10:"
    echo "  sudo apt install python3.10 python3.10-venv"
    exit 1
fi

echo "=== Creating new venv ==="
cd ~/ComfyUI
rm -rf venv_fixed
$PY -m venv venv_fixed

echo "=== Activating venv ==="
source venv_fixed/bin/activate

echo "=== Installing PyTorch ROCm ==="
pip install torch==2.10.0+rocm7.2.1 --index-url https://download.pytorch.org/whl/rocm7.2

echo "=== Installing ComfyUI dependencies ==="
pip install -r requirements.txt

echo "=== GPU test ==="
python3 - << 'EOF'
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
EOF

echo "=== DONE ==="
echo "Run ComfyUI with:"
echo "source ~/ComfyUI/venv_fixed/bin/activate"
echo "python3 main.py"
