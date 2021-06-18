#**********************************************************************************************
# Tutorial 1 A Code
# By: David Byrne
# Objectives: this code provides a simple overview of R windows, comments
# print statements, and loading data
#**********************************************************************************************


#**********************************************************************************************
# 1. COMMENTS: #
# You can insert a comment in any part of your R file by using a hash "#"
# As you can see, I have been writing comments the entire time!
# Comments are not saved as part of your R file output, and they do not 
# affect what your R outputs in the Console window below

# Commenting is an important part of using statistical packages
# It allows you to write notes through your R files to let the reader know
# what the code is actually doing. It is important to have very-well 
# comment R files for this reason, both for your tutors, and for yourself! 
# When you write an R file, step away from it, and then go back to it, 
# it is extremely helpful to have well commented code so you can remember
# what your were doing

# As you can see, I also tend to use commented out lines with lots of 
# stars to divide up my R files into sections. I find this helpful 
# for keeping track of what parts of the code are trying to do what. 
# Feel free to come up with your own R file style, but whatever that
# style is, make sure it is well-commented!

# One other coding convention I will try to use is to use just one #
# while writing comments to explain the code (like I am doing here)
# while I will use two ## in comments that are just before I run a 
# command in the code


#**********************************************************************************************
# 2. WORKING DIRECTORIES: setwd(), getwd()
# Always start your R code by setting the directory to the folder where the 
# R file is located. You can do this with the command setwd
# Change the directory in quotes " " to where you saved your tute1.R file

# Mac: to find the directory where the file is on Mac, right click the 
# tute1.R file whereever you saved it on your computer, choose "Get Info",
# then copy-and-paste the directory listed next to "Where" in the window
# that came up with you right clicked 

# Windows: to find the directory where the file is on Windows, right click the 
# tute1.R file whereever you saved it on your computer, choose "Properties",
# then copy-and-paste the directory listed next to "Location" in the window
# that came up with you right clicked 

# Dave's recommendation for the subject is to create a separate 
# folder for each tutorial (Tute1, Tute2,...,Tute12) and
# in each week save the A Code, B Code, and data provided as part 
# of that week's tutorial in a separate tutorial folder

# Note that the current working directory below is from Dave's computer
# You will need to change this to your working directory to get started
# Also notice how, unlike comments, the active command setwd is black, 
# not green (for comments) under the default colour format of R

# Once you have found the working directory where you saved tute1.R
# you are ready to use it to set the working director for your project
# To run the setwd() command two lines below, highlight the entire line
# and hit the "Run" command in the top righthand corner of your 
# R-scripting window for tute1.R. For reference, go back to the 
# 20001_tutorial1_intro.pdf tutorial document for how to run commands

## Setting the working directory - setwd()
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial1")

# You can check that you are in the right working director with getwd()
# The working directory will be printed out in the Console panel below
# once you run the command. To run this, highlight getwd() and click Run

## Checking the working directory to make sure it is right
getwd()


#**********************************************************************************************
# 3. PRINT STATEMENTS: print()
# Now that we have comments and our working directory is set, we are ready
# to run our very first R commands
# We start with the print() command, which simply prints either strings
# or numbers out in the Console window below

# Print your very first R output!
# This type output is called a "string" which is just text
# You will see "Hellow World" show up below in the Console window
# after running this line of the R file. Notice how I use ## just before 
# in the comment just before running the print() command

## Print Hello world
print("Hello world!")

## Print your second R output!
print("R says: Hello! How are you?")

## Print can also print numbers without quotes
print(20001)


#**********************************************************************************************
# 4. LOADING AND VIEWING DATA: read.csv(), View(), names(), dim()
# Throughout the subject, we will be working with various datasets to 
# learn and apply econometric techniques to real-world data and problems
# The dataset we will work with is tutors.csv. This can be downloaded from
# the LMS site. Please save it in the folder where you saved your 
# tute1.R file. 

# Why do we work with Comma Separated Values (.csv) files and not Excel
# (.xlsx) files? The main reason is that .csv files are "format independent"
# data files, which basically means it does not matter if you save and open 
# .csv files on a Mac computer, Windows computer, or any other type of
# of computer. They will always work. This is not true for Excel files, and
# it can lead to unnecessary headaches and confusion. If, however, you want to 
# view a .csv file in Excel, this is no problem at all. In working with R,
# we will use .csv data files for the entire subject as it best-practice 
# for data work in research, and with government and industry. 

# You use the read.csv() file to load .csv file datasets into R
# In using this command, you need to give a name to your dataset
## Load the .csv file dataset which creates the dataset with the name data
data=read.csv(file="tute1_tutors.csv")

# You can now view your dataset with the View() command below
# Notice how this opens a new tab above next to the tute1.R tab
# After running this command, you can click between your tute1.R
# tab and the data tab to move back and forth between your R
# file and your dataset. As an alternative to using the View()
# command, you can just click on data in the Environment Window
# on the far right hand side of your R-Studio window.
## View your dataset data
View(data)

# You can list the names of the variables in your dataset with names()
# The command lists the variable names in the Console window below
## List the names of the variables in your dataset data
names(data)

# You can also view the 2 dimensions of your dataset with dim()
# The dimensions are the number of observations and the number of variables
# Our example here returns 11 4 in the Console window below. 
# You have 11 observations and 4 variables
## Dimensions of your dataset data
dim(data)

# If you ever want to clear the dataset in your Environment
# and start all over, you can use the following command
## Clear dataset data in the environment window
rm(list = ls())


