---
title: Train PyTorch With GPU Acceleration on Mac, Apple Silicon M2 Chip Machine Learning Benchmark
date: 2022-12-15 22:24:09
categories:
  - ai
tags:
  - pytorch
  - macOS
---

If you're a Mac user and looking to leverage the power of your new Apple Silicon M2 chip for machine learning with PyTorch, you're in luck. In this blog post, we'll cover how to set up PyTorch and optimizing your training performance with GPU acceleration on your M2 chip.

We'll also include some benchmark results to give you an idea of the potential speedup you can expect. So if you're ready to get started with PyTorch on your M2 chip, read on!

## How to Install

Note that the MPS acceleration is not available until macOS 12.3+

If you have the anaconda or miniconda installed. You can install it by using command `conda install pytorch torchvision -c pytorch-nightly`

Here is the GPU utilisation after using this version of pytorch to train the MNIST handwriting dataset.

![GPU](https://i.imgur.com/kRnDZFK.png)

## Show Me the Code

This demo uses PyTorch to build a handwriting recognition model. It also uses the MNIST dataset, which consists of images of handwritten digits, and trains a convolutional neural network (CNN) to classify the images.

```
import torch
from torch import nn
from torch.utils.data import DataLoader
from torchvision.datasets import MNIST
from torchvision.transforms import ToTensor

print(f"PyTorch version: {torch.__version__}")

# Check PyTorch has access to MPS (Metal Performance Shader, Apple's GPU architecture)
print(f"Is MPS (Metal Performance Shader) built? {torch.backends.mps.is_built()}")
print(f"Is MPS available? {torch.backends.mps.is_available()}")

# Set the device
device = "mps" if torch.backends.mps.is_available() else "cpu"
device = torch.device(device)
print(f"Using device: {device}")


# Define the CNN model
class HandwritingRecognitionModel(nn.Module):
    def __init__(self):
        super().__init__()

        # Define the convolutional layers
        self.conv1 = nn.Conv2d(1, 16, kernel_size=3, padding=1)
        self.conv2 = nn.Conv2d(16, 32, kernel_size=3, padding=1)

        # Define the pooling and dropout layers
        self.pool = nn.MaxPool2d(2, 2)
        self.dropout1 = nn.Dropout(0.25)
        self.dropout2 = nn.Dropout(0.5)

        # Define the fully connected layers
        self.fc1 = nn.Linear(32 * 7 * 7, 128)
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        # Pass the input through the convolutional layers
        x = self.conv1(x)
        x = self.pool(x)
        x = self.dropout1(x)
        x = self.conv2(x)
        x = self.pool(x)
        x = self.dropout2(x)

        # Reshape the output for the fully connected layers
        x = x.view(-1, 32 * 7 * 7)

        # Pass the output through the fully connected layers
        x = self.fc1(x)
        x = self.fc2(x)

        # Return the final output
        return x


# Load the MNIST dataset
train_dataset = MNIST("./data", train=True, download=True, transform=ToTensor())
test_dataset = MNIST("./data", train=False, download=True, transform=ToTensor())

# Define the data loaders
train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=64, shuffle=False)

# Define the model
model = HandwritingRecognitionModel().to(device)

# Define the loss function and optimizer
loss_fn = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)

# Train the model for 10 epochs
for epoch in range(10):
    # Set the model to training mode
    model.train()

    # Iterate over the training data
    for images, labels in train_loader:
        images, labels = images.to(device), labels.to(device)
        # Pass the input through the model
        outputs = model(images)

        # Compute the loss
        loss = loss_fn(outputs, labels)

        # Backpropagate the error
        loss.backward()

        # Update the model parameters
        optimizer.step()

    # Set the model to evaluation mode
    model.eval()

    # Evaluate the model on the validation set
    with torch.no_grad():
        correct = 0
        total = 0

        for images, labels in test_loader:
            images, labels = images.to(device), labels.to(device)
            # Pass the input through the model
            outputs = model(images)

            # Get the predicted labels
            _, predicted = torch.max(outputs.data, 1)

            # Update the total and correct counts
            total += labels.size(0)
            correct += (predicted == labels).sum()

        # Print the accuracy
        print(f"Epoch {epoch + 1}: Accuracy = {100 * correct / total:.2f}%")

```


It's 1.5 times faster than the CPU version of code.

## Benchmark

The output of the MPS version, which utilises the GPU, is as below.

```
PyTorch version: 2.0.0.dev20221214
Is MPS (Metal Performance Shader) built? True
Is MPS available? True
Using device: mps
Epoch 1: Accuracy = 62.04%
Epoch 2: Accuracy = 81.67%
Epoch 3: Accuracy = 89.39%
Epoch 4: Accuracy = 89.84%
Epoch 5: Accuracy = 89.87%
Epoch 6: Accuracy = 91.45%
Epoch 7: Accuracy = 94.71%
Epoch 8: Accuracy = 93.32%
Epoch 9: Accuracy = 95.26%
Epoch 10: Accuracy = 94.63%

________________________________________________________
Executed in   55.08 secs    fish           external
   usr time   49.89 secs   64.00 micros   49.89 secs
   sys time    5.13 secs  921.00 micros    5.13 secs

```

The output of the CPU version is as below.

```
PyTorch version: 2.0.0.dev20221214
Is MPS (Metal Performance Shader) built? True
Is MPS available? True
Using device: cpu
Epoch 1: Accuracy = 49.73%
Epoch 2: Accuracy = 73.65%
Epoch 3: Accuracy = 88.25%
Epoch 4: Accuracy = 86.27%
Epoch 5: Accuracy = 90.01%
Epoch 6: Accuracy = 94.28%
Epoch 7: Accuracy = 92.18%
Epoch 8: Accuracy = 86.54%
Epoch 9: Accuracy = 90.70%
Epoch 10: Accuracy = 93.63%

________________________________________________________
Executed in  141.26 secs    fish           external
   usr time  202.16 secs    0.07 millis  202.16 secs
   sys time   69.79 secs    1.19 millis   69.79 secs   
```

Both the CPU and GPU in this benchmark were on the same M2 chip.

The time spent with the CPU was 141.26 seconds, about 2.5 times the GPU version.

Although it's not too much of an improvement if compared to the newest NVIDIA GPUs, it is still a great leap for Mac users in the Machine Learning field.

