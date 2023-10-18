from datetime import datetime
import numpy as np
import torch
import torch.nn as nn
import tqdm.notebook as tq
import wandb
import torchmetrics
from torch.utils.data import DataLoader

import pandas as pd
import seaborn as sn
import matplotlib.pyplot as plt

# Determine which device on import, and then use that elsewhere.
device = torch.device("cpu")
if torch.cuda.is_available():
    device = torch.device("cuda:0")
    torch.cuda.set_device(device)


def plot_confusion_matrix(cm, class_names):
    '''
        cm: the confusion matrix that we wish to plot
        class_names: the names of the classes 
    '''

    # this normalizes the confusion matrix
    cm = cm.astype(np.float32) / cm.sum(axis=1)[:, None]
    
    df_cm = pd.DataFrame(cm, class_names, class_names)
    ax = sn.heatmap(df_cm, annot=True, cmap='flare')

    ax.set_xlabel('Predicted')
    ax.set_ylabel('True')
    plt.show()
    
def count_classes(preds):
    '''
    Counts the number of predictions per class given preds, a tensor
    shaped [batch, n_classes], where the maximum per preds[i]
    is considered the "predicted class" for batch element i.
    '''
    pred_classes = preds.argmax(dim=1)
    n_classes = preds.shape[1]
    return [(pred_classes == c).sum().item() for c in range(n_classes)]

def train_epoch(epoch, model, optimizer, criterion, loader, num_classes, device):
    '''
    Train the model on the entire training set precisely once (one epoch).
    Lab 6 has a very similar function.
    '''

    model.train()

    # Initialize metrics
    # TODO: Task 1b - initialize the following torchmetrics metrics
    #       the average epoch loss per example
    #       accuracy
    #       unweighted average recall
    
    loss_metric = torchmetrics.MeanMetric().to(device)
    acc_metric = torchmetrics.Accuracy(task='multiclass', num_classes= 7).to(device)
    uar_metric = torchmetrics.Recall(task='multiclass',average='macro',num_classes= 7).to(device)

    for i, (inputs, lbls) in enumerate(loader):
        inputs, lbls = inputs.to(device), lbls.to(device)

        # Update model weights
        # TODO: Task 1b - Use the batch to update the weights of the model
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, lbls)
        loss.backward()
        optimizer.step()
        # Accumulate metrics
        # TODO: Task 1b - accumulate each of the 3 metrics you initialized.
        loss_metric(loss)
        acc_metric(outputs, lbls)
        uar_metric(outputs, lbls)

    # Calculate epoch metrics, and store in a dictionary for wandb
    # TODO Task 1b - compute the three metrics 
    # metrics_dict = {
    #     'Loss_train': ...,
    #     'Accuracy_train': ...,
    #     'UAR_train': ...,
    # }
    # Calculate epoch metrics, and store in a dictionary for wandb
    metrics_dict = {
        'Loss_train': loss_metric.compute(),
        'Accuracy_train': acc_metric.compute(),
        'UAR_train': uar_metric.compute(),
    }

    return metrics_dict

def val_epoch(epoch, model, criterion, loader, num_classes, device):
    '''
    Evaluate the model on the entire validation set.
    '''
    model.eval()
    
    # Initialize metrics
    # TODO: Task 1b - initialize the following torchmetrics metrics
    #       the average epoch loss per example
    #       accuracy
    #       unweighted average recall
    loss_metric = torchmetrics.MeanMetric().to(device)
    acc_metric = torchmetrics.Accuracy(task='multiclass', num_classes= 7).to(device).to(device)
    uar_metric = torchmetrics.Recall(task='multiclass',average='macro',num_classes= 7).to(device)
    # TODO: Task 1c - initialize a confusion matrix torchmetrics object
    cm_metric = torchmetrics.ConfusionMatrix(num_classes)
    
    for inputs, lbls in loader:
        inputs, lbls = inputs.to(device), lbls.to(device)

        # TODO Task 1b - Obtain validation loss (use torch.no_grad())
        outputs = model(inputs)
        loss = criterion(outputs, lbls)

        # TODO: Task 1b - accumulate each of the 3 metrics you initialized
        #       Look at trainer.py of lab 6 for inspiration.
        #       This will take the loss, outputs and lbls from this batch
        #       to update each of the metric object's internal state. 
        loss_metric(loss)
        acc_metric(outputs, lbls)
        uar_metric(outputs, lbls)
        cm_metric(outputs, lbls)   
        # TODO: Task 1c - acculmate confusion matrix 
        cm_metric = torchmetrics.ConfusionMatrix(num_classes)
    # Calculate epoch metrics, and store in a dictionary for wandb
    # TODO Task 1b - compute the three metrics 
    # metrics_dict = {
    #     'Loss_val': ...,
    #     'Accuracy_val': ...,
    #     'UAR_val': ...,
    # }
    metrics_dict = {
        'Loss_val': loss_metric.compute(),
        'Accuracy_val': acc_metric.compute(),
        'UAR_val': uar_metric.compute(),
    }    

    # Compute the confusion matrix
    # TODO: Task 1c - compute the confusion matrix and store it in cm
    cm = cm_metric.compute().cpu().numpy()

    return metrics_dict, cm
    


def train_model(model, train_loader, val_loader, optimizer, criterion,
                class_names, n_epochs, project_name, ident_str=None):
                
    num_classes = len(class_names)
    model.to(device)
    
    # Initialise Weights and Biases (wandb) project
    if ident_str is None:
      ident_str = datetime.now().strftime("%Y%m%d_%H%M%S")
    exp_name = f"{model.__class__.__name__}_{ident_str}"
    run = wandb.init(project=project_name, name=exp_name)

    try:
        # Train by iterating over epochs
        for epoch in tq.tqdm(range(n_epochs), total=n_epochs, desc='Epochs'):
            train_metrics_dict = train_epoch(epoch, model, optimizer, criterion,
                    train_loader, num_classes, device)
                    
            val_metrics_dict, cm = val_epoch(epoch, model, criterion, 
                    val_loader, num_classes, device)
            wandb.log({**train_metrics_dict, **val_metrics_dict})
    finally:
        run.finish()

    # Plot confusion matrix from results of last val epoch
    # TODO Task 1c - call plot_confusion_matrix with appropriate arguments.
    plot_confusion_matrix(cm, class_names)