import torch
import torch.nn as nn
import torchvision

# TODO Task 1c - Implement a SimpleBNConv
class SimpleBNConv(nn.Module):
    def __init__(self,device):
        super().__init__()

        self.seq = nn.Sequential(
          nn.Conv2d(3, 8, 3),
          nn.ReLU(),
          nn.BatchNorm2d(8),
          nn.MaxPool2d(2),
          nn.Conv2d(8, 16, 3),
          nn.ReLU(),
          nn.BatchNorm2d(16),
          nn.MaxPool2d(2),
          nn.Conv2d(16, 32, 3),
          nn.ReLU(),
          nn.BatchNorm2d(32),
          nn.MaxPool2d(2),
          nn.Conv2d(32, 64, 3),
          nn.ReLU(),
          nn.BatchNorm2d(64),
          nn.MaxPool2d(2),
          nn.Conv2d(64, 128, 3),
          nn.ReLU(),
          nn.BatchNorm2d(128),
          nn.MaxPool2d(2)
        )
        self.to(device)

    def forward(self, x):
        x = self.pool1(self.bn1(self.relu1(self.conv1(x))))
        return self.seq(x)

# TODO Task 1f - Create a model from a pre-trained model from the torchvision
#  model zoo.


# TODO Task 1f - Create your own models


