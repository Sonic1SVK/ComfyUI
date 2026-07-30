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
