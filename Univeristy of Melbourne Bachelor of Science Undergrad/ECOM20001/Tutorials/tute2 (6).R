#**********************************************************************************************
# Tutorial 2 Code
# By: David Byrne
# Objectives: visualising data with R, descriptive statistics
#**********************************************************************************************


#**********************************************************************************************
# 1. SET WORKING DIRECTORY AND LOAD DATA

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial2")

## Load the dataset from a comma separate value
data=read.csv(file="tute2_crime.csv")

## List the variables in the dataset named data
names(data)

## Dimension of the dataset: 45 observations (states), 5 variables
dim(data)

# Variable descriptions
  # stateid - identifier for a US state
  # vio - violent crime rate — incidents per 100,000 people 
  # rob - robbery rate — incidents per 100,000 people
  # density - population per square mile of land
  # avginc - real per capita personal income in the state


#**********************************************************************************************
# 2. VISUALISING DATA: hist(), plot(), density(), boxplot()

# A. HISTOGRAMS: hist()
# One way to visualise a distribution is with a histogram. These are 
# a great way to start looking at your data, in particular seeing 
# what value a certain variable is centered around, and how spread out 
# the data are around its central value. 

# A histogram takes a bunch of "bins" of data, and computes the 
# number of data points that sit in each of the bins. 

# So, for example, if we created bins of 0-100, 100-200, 200-300
# and so on for our violence variable, vio, we would find that
# 2 states have a vio between 0-100, 3 states between 100-200
# 8 states between 200-300, and so on. 

# The command for creating histograms is hist()
# and we access the vio variable from our dataset data
# using a dollar sign $. Specifically: 
  # data$vio - accesses the vio variable
  # data$rob - accesses the rob variable
  # data$dens - accesses the density variable
  # data$avginc - accesses the avginc variable

## Create a historgram for our violence variable, vio
hist(data$vio)

# Notice what happend when you ran this command. 
# In the bottom right hand corner of your R-Studio
# screen that the histogram appear. Congrats! You just created 
# your first visualisation of data in R

## Create histograms for other variables with R-chosen bins
hist(data$rob)
hist(data$dens)
hist(data$avginc)


# B. PROBABILITY DENSITIES: plot() and density()
# Closely related to histograms are probability densities (or just densities)
# Recall from the lecture notes that for a continuous random variable X
# and values a and b, that probability densities tell us the probability
# of randomly obtaining an X value between a and b: P(a<X<b)
# We can create probability densities by combining the plot() and density()
# commands. Comparing these graphs to the hist() graphs yield similar 
# insight into the point of central tendency and spread of each variable in the data

## Compute probability density for vio variable
plot(density(data$vio)) 

## Create probability densities for other variables in the data
plot(density(data$rob)) 
plot(density(data$dens)) 
plot(density(data$avginc)) 


# C. BOX AND WHISKER PLOTS: boxplot()
# Box and whisker plots provide a different sort of visualisation of 
# a random variable's central tendency and spread. Specifically, they
# create visualisations based on the following percentiles of the distribution:
  # Median or 50th percentile (the middle point of a distribution)
  # 25th and 75th percentiles (intermediate low and high values of a distribution)
  # Min and Max value         (extreme low and high values of a distribution)

# The "box" in the plot is constructed using the 75th percentile (top of the box), 
# 50th percentile (dark line in box), and 25th percentile (bottom of the box). 
# Note that the 25th, 50th, and 75th percentiles are also called the quartiles
# of the distribution, and the width of the box in a box and whisker plot 
# visualises the Inter-quartile Range of a variable

# The "whiskers" in the plot are constructed using the Max value (very top line in the 
# the plot connected by a dash line), and the Min value (very bottom line in the 
# the plot connected by a dash line) 

## Create box and whisker plot for vio variable
boxplot(data$vio)

## Create box and whisker plot for other variables in the data
boxplot(data$rob)
boxplot(data$dens)
boxplot(data$avginc)


# D. SCATTER PLOTS: plot()
# So far we have considered ways to describe ONE variable visually. We now introduce
# one of the most important ways for describing TWO variables visually: scatter plots.
# A scatter plot involves defining an x-axis (horizontal axis) and a y-axis (vertical axis).
# To construct a scatter plot, we plot the (x,y) values for all the observations in
# our dataset. 

## Create scatter plot for vio (x-variable) vs rob (y-variable)
plot(data$vio,data$rob)

## Create other scatterplots looking at how vio and rob (y-variables) 
## relate to density and avginc (x-variables)
plot(data$dens,data$vio)
plot(data$dens,data$rob)

plot(data$avginc,data$vio)
plot(data$avginc,data$rob)



#**********************************************************************************************
# 3. SAVING GRAPHS, MAKING NICE GRAPHS: pdf(), png(), jpeg(), bmp(), postscript(), dev.off

# A. SAVING GRAPHS: pdf(), png(), jpeg(), bmp(), postscript(), dev.off
# Rather than just looking at our graphs as we construct them in the plots
# window in the bottom-right hand part of R-Studio, we can also save the
# graphs to our working directory for presentations or assignments
# You can save graphs in a variety of formats including PDF, PNG, JPEG, BMP, PS
# I tend to work with PDF files because they tend to be consistently 
# handled and read across various word processors, but feel free to use other formats

# There are three lines needed to create and save a graph
  # 1. Code for creating the graph file
  # 2. Code for computing the graph in R-Studio (this is what we have done so far)
  # 3. Code for finalising and publishing the graph file
# Below I illustrate these three required lines for graphing
# Notice my naming convention for files is: "fig_figuretype_variables.pdf"
# By putting the "fig_basic" suffix, I ensure all of my basic graphs are saved close
# together in the working director

## Graph histogram of vio
pdf("fig_basic_hist_vio.pdf")
hist(data$vio)
dev.off()

## Graph density of rob
pdf("fig_basic_hist_rob.pdf")
plot(density(data$rob)) 
dev.off()

## Box and whisker plot of avginc
pdf("fig_basic_boxplot_avginc.pdf")
boxplot(data$avginc)
dev.off()

## Graph scatter plot of robbery vs density
pdf("fig_basic_scatter_dens_rob.pdf")
plot(data$dens,data$rob)
dev.off()

# To create other graph types you swap out the pdf() in the first line
# For example, with the last scatter plot graph, we can create PNG, JPEF, BMP, PS
# files by swapping out pdf("fig_scatter_dens_rob.pdf") with either
# png("fig_basic_scatter_dens_rob.png")
# jpeg("fig_basic_scatter_dens_rob.jpg")
# bmp("fig_basic_scatter_dens_rob.bmp")
# postscript("fig_basic_scatter_dens_rob.ps")

# When you highlight all three lines to produce a graph
# in your working directory, it will not update the graph in the plots
# viewer in the bottom right corner of R-Studio. If you want to view the graph
# in the bottom right corner and not publish it, just highlight the line with 
# hist()/plot()/boxplot() and click 'run'. If you want to publish the graph in
# the working directory, highlight all 3 lines and click run, as just discussed

# B. MAKING NICE GRAPHS
# The graphs we have produced so far are somewhat rough: they do not have
# titles, the axes are unlabeled, and they are black and white. We can
# use various options in making graphs to make them look nicer
# I have updated my suffice in the file names to "fic_nice"

## Graph scatter plot of robbery vs density with a main title
pdf("fig_nice_scatter_dens_rob.pdf")
plot(data$dens,data$rob, main="Relationship Between Robbery Rate and Population Density")
dev.off()
# Notice that this is the same as plot(data$dens,data$rob) except we
# added a comma and then main="". The comma signifies that you are choosing
# and option within the plot() command, which in this case is main for the main 
# graph tite

# We can also added many other options to our plot command including 
# axes titles and graph color
## Graph scatter plot of robbery vs density with a main title, axis titles, color
pdf("fig_nice_scatter_dens_rob.pdf")
plot(data$dens,data$rob, 
     main="Relationship Between Robbery Rate and Population Density",
     xlab="Population per Square Mile of Land",
     ylab="Robbery Rate per 100,000 People",
     col="red",
     pch=16)
dev.off()

# Notice how each graph option is separated by a comma ","
# Also put each option on a separate line by hitting enter; 
# this still keeps all the options within the same graph
# The options I have used are:
  # main - main title of the graph
  # xlab - title for the x-axis
  # ylab - title for the y-axis
  # col - colour of the scatter plot dots
  # pch=16 - fills in the scatter plot dots

## Graph histogram of vio, more nicely done
pdf("fig_nice_hist_vio.pdf")
hist(data$vio,
     main="Histogram of Violent Crimes Rate",
     xlab="Violent Crimes Rate per 100,000 People",
     ylab="Frequency",
     col="blue",
     pch=16)
dev.off()

## Graph density of rob, more nicely done
pdf("fig_nice_density_rob.pdf")
plot(density(data$rob),
     main="Density of Robbery Rate",
     xlab="Robberies per 100,000 People",
     ylab="Density",
     col="orange")
dev.off()

## Box and whisker plot of avginc, more nicely done
pdf("fig_nice_boxplot_avginc.pdf")
boxplot(data$avginc,
        main="Box and Whisker Plot of Per Capita Income",
        col="purple")
dev.off()

## Other (nice) scatter plots to be discussed in the tutorial or presented in the solutions

# Robbery and Violent Crime Rate
pdf("fig_nice_scatter_rob_vio.pdf")
plot(data$vio,data$rob, 
     main="Relationship Between Robbery Rate and Violent Crime Rate",
     xlab="Violent Crime Rate per 100,000 People",
     ylab="Robbery Rate per 100,000 People",
     col="blue",
     pch=16)
dev.off()

# Violent Crime Rate and Population Density
pdf("fig_nice_scatter_avginc_vio.pdf")
plot(data$avginc,data$rob, 
     main="Relationship Between Robbery Rate and Per Capita Income",
     xlab="Per Capita Income",
     ylab="Robery Rate per 100,000 People",
     col="black",
     pch=16)
dev.off()

## Graph density of vio, dens, avginc, more nicely done
pdf("fig_nice_density_vio.pdf")
plot(density(data$vio),
     main="Density of Violent Crimes Rate",
     xlab="Violent Crimes Rate per 100,000 People",
     ylab="Density",
     col="orange")
dev.off()

pdf("fig_nice_density_dens.pdf")
plot(density(data$dens),
     main="Density of People Per Square Mile",
     xlab="People Per Square Mile",
     ylab="Density",
     col="orange")
dev.off()

pdf("fig_nice_density_avginc.pdf")
plot(density(data$avginc),
     main="Per Capita Income (in $000's)",
     xlab="Per Capita Income",
     ylab="Density",
     col="orange")
dev.off()


#**********************************************************************************************
# 4. DESCRIPTIVE STATISTICS: sapply(), quantile(), IQR()

# Descriptive statistics are also a useful way of getting a feel for your data
# Using visuals and descriptive statistics in tandem are how most econometric analyses begin
# We start with a command for getting basic summary statistics 

## Descriptive Statistics:  sapply() returning Mean, Standard Deviation, Min, Max, Median
sapply(data, mean)    # Means
sapply(data, sd)      # Standard Deviation
sapply(data, min)     # Min
sapply(data, max)     # Max
sapply(data, median)  # Median

## You can also quickly get summary statistics using the summary() and sapply() commands together
summary(data)     # Mean, Min, Max, Median, 25th percentile, 75th percentile
sapply(data,sd)   # Standard Deviation

## Quartiles: quantile() returns the 5 key elements of Box and Whisker Plot
## min (0%), 25th percentile, 50th percentile, 75th percentile, max (100%)
quantile(data$vio)
quantile(data$rob)
quantile(data$dens)
quantile(data$avginc)

# quantile() can also be used to return specifc percentiles of a distribution

# Example: returning 32nd, 57th, 98th percentile of average income 
quantile(data$avginc, c(.32, .57, .98))

# Example: returning 8th percentile of robbery rate
quantile(data$avginc, c(.08))

## IQR() quickly returns the inter-quartile range for a variable
# Recall from Lecture 2 notes: IQR = 75th percentile - 25th percentile
IQR(data$vio)
IQR(data$rob)
IQR(data$dens)
IQR(data$avginc)






