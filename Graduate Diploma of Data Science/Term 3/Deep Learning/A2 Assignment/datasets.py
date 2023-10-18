import collections
import csv
from pathlib import Path

import pandas as pd
import numpy as np
import torch
import torchvision.transforms as transforms
from PIL import Image

import os

# TODO Task 1b - Implement LesionDataset
#        You must implement the __init__, __len__ and __getitem__ methods.
#
#        The __init__ function should have the following prototype
#          def __init__(self, img_dir, labels_fname):
#            - img_dir is the directory path with all the image files
#            - labels_fname is the csv file with image ids and their 
#              corresponding labels
#        Note: You should not open all the image files in your __init__.
#              Instead, just read in all the file names into a list and
#              open the required image file in the __getitem__ function.
#              This prevents the machine from running out of memory.
#
# TODO Task 1e - Add augment flag to LesionDataset, so the __init__ function
#                now look like this:
#                   def __init__(self, img_dir, labels_fname, augment=False):
#

import csv
from pathlib import Path
from PIL import Image

class LesionDataset(torch.utils.data.Dataset):
    def __init__(self, img_dir, labels_fname):
        self.img_dir = Path(img_dir)
        self.labels_fname = pd.read_csv(labels_fname)
        self.file_names = list(self.img_dir.glob("*.jpg"))

    def __len__(self):
        return len(self.labels_fname)

    def __getitem__(self, idx):
        image_id = self.labels_fname.iloc[idx, 0]
        image_path = self.img_dir / (image_id + '.jpg')
        label = self.labels_fname.iloc[idx, 1]
        image = Image.open(image_path)
        return image, label

