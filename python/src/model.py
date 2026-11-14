import torch
from torch import nn
from torch.utils.data import DataLoader
from torchvision import datasets, transforms


class CNN_MNIST(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(1, 32, 3, padding=1)
        self.conv2 = nn.Conv2d(32, 64, 3, padding=1)
        self.pool  = nn.MaxPool2d(2)
        self.relu  = nn.ReLU()
        self.fc1   = nn.Linear(64 * 7 * 7, 128)
        self.fc2   = nn.Linear(128, 10)

    def forward(self, x):
        x = self.pool(self.relu(self.conv1(x)))   # 1×28×28  → 32×14×14
        x = self.pool(self.relu(self.conv2(x)))   # 32×14×14 → 64×7×7
        x = torch.flatten(x, 1)                   # → 3136
        x = self.relu(self.fc1(x))                # → 128
        return self.fc2(x)                        # → 10 scores



class CNN_CIFAR10(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(3, 32, 3, padding=1, bias=False)
        self.bn1   = nn.BatchNorm2d(32)
        self.conv2 = nn.Conv2d(32, 64, 3, padding=1, bias=False)
        self.bn2   = nn.BatchNorm2d(64)
        self.conv3 = nn.Conv2d(64, 128, 3, padding=1, bias=False)
        self.bn3   = nn.BatchNorm2d(128)
        self.pool  = nn.MaxPool2d(2)
        self.relu  = nn.ReLU()
        self.drop  = nn.Dropout(0.3)
        self.fc1   = nn.Linear(128 * 4 * 4, 256)
        self.fc2   = nn.Linear(256, 10)
    def forward(self, x):
        x = self.pool(self.relu(self.bn1(self.conv1(x))))   # 3×32×32   → 32×16×16
        x = self.pool(self.relu(self.bn2(self.conv2(x))))   # 32×16×16  → 64×8×8
        x = self.pool(self.relu(self.bn3(self.conv3(x))))   # 64×8×8    → 128×4×4
        x = torch.flatten(x, 1)                             # → 2048
        x = self.drop(x)
        x = self.relu(self.fc1(x))                          # → 256
        x = self.drop(x)
        return self.fc2(x)                                  # → 10 scores


