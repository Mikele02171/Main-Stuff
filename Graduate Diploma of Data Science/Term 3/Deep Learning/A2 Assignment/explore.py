import matplotlib.pyplot as plt
import numpy as np

def plot_label_distribution(labels, split, class_names):
    # This function plots the class distribution for a given list of labels
    # The parameters are the following:
    #   labels: list of integers indicating the class of each example 
    #   split: a string specifying the split name you are ploting.
    #          This is used in the title of the graph.
    #          - e.g. 'train' or 'val'
    #   class_names: a list of class names corresponding to each class
    #                - e.g. "MEL", "NV", "BCC", "AKIEC", "BKL", "DF", "VASC"
    
    # Given a flat list of integers `labels`, counts how many of each
    counts = [ sum(labels == c) for c in range(len(class_names)) ]

    # Plot a histogram of the distribution
    plt.title(f'{split} distribution')
    plt.bar(class_names, counts)
    plt.xlabel('Class')
    plt.ylabel('Num examples')
    plt.show()
