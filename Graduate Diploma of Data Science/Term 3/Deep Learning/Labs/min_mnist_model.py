# This file is constructed by pulling the minimal set of instructions from the lab to train a model.
# I have stripped out all comments, data exploration and testing.
# This code is useless in practice because if a model is untested,
#  then we have no knowledge of whether it is a good model.
# The purpose of this code is to highlight that there are not many core steps strictly required,
#  and most of the complexity comes in when you need to monitor performance.



# ========================================================================================
#                                    Training Data loading
# ========================================================================================
# Only loading the training data.
import pandas as pd
import numpy as np
import torch

trainval_df = pd.read_csv("https://ashwhall.github.io/download/mnist_csv/mnist_train.zip", header=None)
train_df = trainval_df.sample(frac=0.8, random_state=42)

images = torch.tensor(np.array(train_df.iloc[:, 1:]), dtype=torch.float32)\
            .reshape(-1, 1, 28, 28)
labels = torch.tensor(np.array(train_df.iloc[:, 0]))

train_dataset = torch.utils.data.TensorDataset(images, labels)
train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=256, shuffle=True)


# ========================================================================================
#                                            Model
# ========================================================================================
import torch.nn as nn
class NotAGoodModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.seq = nn.Sequential(
            nn.Conv2d(1, 8, 3, padding=1),
            nn.ReLU(),
            nn.Conv2d(8, 4, 3, padding=1),
            nn.ReLU(),
            nn.Flatten(),
            nn.Linear(4*28*28, 10)
        )
    def forward(self, x):
        return self.seq(x)

model = NotAGoodModel()

# ========================================================================================
#                                    Minimal Training loop
# ========================================================================================
# This will train a model, but that is all.
# Minimal monitoring, no testing.
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.0001)
num_epochs = 10

for epoch in range(num_epochs):
    for i, (image, label) in enumerate(train_loader):
        output = model(image)
        loss = criterion(output, label)
        loss.backward()
        optimizer.step()
        print(f'Epoch {epoch:2d}   |   Step {i:4d}   |   Loss {loss:05.3f}', end='\r')
print()
# Ask yourself, though. How do we know if the model trained well? The loss changes too wildly on every batch
