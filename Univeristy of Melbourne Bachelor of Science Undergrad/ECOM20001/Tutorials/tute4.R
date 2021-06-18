#**********************************************************************************************
# Tutorial 4 Code
# By: David Byrne
# Objectives: Hypothesis testing with means, p-values, confidence intervals
#**********************************************************************************************


#**********************************************************************************************
# 1. SET WORKING DIRECTORY AND LOAD DATA

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial4")

## Load the dataset from a comma separate value
data=read.csv(file="tute4_cps.csv")

## List the variables in the dataset named data
names(data)

## Dimension of the dataset
# 15052 observations (individuals)
# 5 variables: year, ahe, bachelor, female, age
dim(data)


#**********************************************************************************************
# 2. INDEXING DATA: [], &

# A. INDEXING VARIABLES
# For computing means for subsets of data (e.g,. 1992/2012 or bachelor/not bachelor or male/female),
# it is useful to be able to index certain observations
# We can index observation "i" for variable "var" using the command var[x]
# Notice this difference in brackets: we use square brackets "[]" to index observations from
# variables in the dataset

## Index observation 1 for ahe
data$ahe[1]    # observation 1 for ahe

## Index observation 37 for female 
data$female[37]   # observation 37 for female

# Use View(data) and check observation 1 and 37 for ahe in the dataset to verify these 
# commands return their values for these observations

# We can also index more than just one observation at a time 
# Specifically, we can index observations "i" to "n" for variable var using the command var[x:n]

## Index observations 1 to 5 for ahe
data$ahe[1:5]

## Index observations 37 to 47 for female
data$female[37:47]

# Use View(data) and check observations 1 to 5 for ahe and observations 37 to 47 for female
# in the dataset and verify that their values correspond to what these commands output in the 
# console window below


# B. SUBSETS OF DATA
# Suppose we want to just look at ahe for females
# We can get all the observations that corresponds to females with female==1
# data$ahe[data$female==1] is ahe for females
# data$ahe[data$female==0] is ahe for males

## Mean and standard deviation of earnings for females
mean(data$ahe[data$female==1])
sd(data$ahe[data$female==1])

## Mean and standard deviation of earnings for males
mean(data$ahe[data$female==0])
sd(data$ahe[data$female==0])

## Mean and standard deviation of earnings for bachelor degree
mean(data$ahe[data$bachelor==1])
sd(data$ahe[data$bachelor==1])

## Mean and standard deviation of earnings for no bachelor degree
mean(data$ahe[data$bachelor==0])
sd(data$ahe[data$bachelor==0])

## Mean and standard deviation of earnings in 1992
mean(data$ahe[data$year==1992])
sd(data$ahe[data$year==1992])

## Mean and standard deviation of earnings in 2012
mean(data$ahe[data$year==2012])
sd(data$ahe[data$year==2012])

# Notice how we use round brackets () for the mean and sd function, but square brackets [] 
# for indexing the ahe variable
# You can similarly index based on individuals with a bachelor's degree ([data$bachelor==1]) and
# without a bachelor's degree ([data$bachelor==0])


# D. SUBSETS OF DATA BASED ON MULTIPLE VARIABLES
# We can also index variables based on multiple variables using the index variables of interest
# and the ampersand & which means AND.
# For example, suppose we want mean and standard deviation of income for females with a 
# bachelor's degree. We index female AND bachelor with [data$female==1 & data$bachelor==1]

## Mean and standard deviation of females with bachelor's degree
mean(data$ahe[data$female==1 & data$bachelor==1])
sd(data$ahe[data$female==1 & data$bachelor==1])

## Mean and standard deviation of males without bachelor's degree (another example)
mean(data$ahe[data$female==0 & data$bachelor==0])
sd(data$ahe[data$female==0 & data$bachelor==0])

## Mean and standard deviation of females without bachelor's degree in 2012 (another example)
mean(data$ahe[data$female==1 & data$bachelor==0 & data$year==2012])
sd(data$ahe[data$female==1 & data$bachelor==0 & data$year==2012])


#**********************************************************************************************
# 3. DESCRIPTIVE STATISTICS: summary(), sapply(), plot(density()), lines(), legend() 

# Let's start with descriptive statistics to get a feel for the data

## Descriptive Statistics for Entire Datasets
summary(data)     # Mean, Min, Max, Median, 25th percentile, 75th percentile
sapply(data,sd)   # Standard Deviation


# B. DESCRIPTIVES FOR SUBSETS OF DATA
## Compare means and standard deviation for ahe for females and males
# Females
summary(data$ahe[data$female==1])
sd(data$ahe[data$female==1])  
# Males
summary(data$ahe[data$female==0])
sd(data$ahe[data$female==0]) 

## Compare means and standard deviation for ahe for bachelor degrees and no bachelor degrees
# Bachelor Degree
summary(data$ahe[data$bachelor==1])
sd(data$ahe[data$bachelor==1])  

# No Bachelor Degree
summary(data$ahe[data$bachelor==0])
sd(data$ahe[data$bachelor==0]) 


# C. DISTRIBUTIONS FOR SUBSETS OF DATA
# When comparing data for two different groups, it is often useful to plot the densities 
# for the two groups in getting a feel for the data

# The R commands you need are listed below: 
# 1. plot(density(x)): plot the density for the first variable x
# 2. lines(density()): plot the density for the second variable y, which will plot the second
# density of interest AFTER you have run the plot(density(x)) command
# 3. legend(): after the plot() and lines() command you can specify the legend for the graph
# below I use "red" and "blue" for the lines in the graph and for constructing the legend

## Density plots for ahe for females and males
# Run only the three middle lines to see the graph in your R plot window
# Run all 5 lines to save the density plot as a PDF file in your working directory
pdf("ahe_female.pdf")
plot(density(data$ahe[data$female==1]), col="red",lty=1,xlab="AHE",main="Gender and Earnings")
lines(density(data$ahe[data$female==0]), col="blue",lty=1)
legend("topright", legend=c("Female", "Male"), col=c("red", "blue"), lty=c(1,1))
dev.off()

## Density plots for ahe for bachelor and no bachelor
# Run only the three middle lines to see the graph in your R plot window
# Run all 5 lines to save the density plot as a PDF file in your working directory
pdf("ahe_bachelor.pdf")
plot(density(data$ahe[data$bachelor==0]), col="red",lty=1,xlab="AHE",main="Education and Earnings")
lines(density(data$ahe[data$bachelor==1]), col="blue",lty=1)
legend("topright", legend=c("No Bachelor Degree", "Bachelor Degree"), col=c("red", "blue"), lty=c(1,1))
dev.off()


#**********************************************************************************************
# 4. TESTING MEANS AND CONFIDENCE INTERVALS: t.test(), length()

# A. TESTING MEANS AND 95% CIs
# We can use the t.test() command to test hypotheses about sample means in R
# The command is run as t.text(var,mu=x) which will test the hypothesis that 
# the mean of the variable var equals x (two-sided alternative)
# Output from t.test(): t-statistic for the test, degrees of freedom (n-1), p-value, 95% CI, 
# and sample mean of variable test is based on

## Test the null that the true value of the mean of ahe is 0 (example)
# Note p-value < 2.2e-16 in the output means the p-value is effectively 0 
# That is, we strongly reject the null
t.test(data$ahe,mu=0)

## Test the null that the true value of the mean of ahe is 19.5 (example)
t.test(data$ahe,mu=19.5)

## Test the null that the true value of the mean of ahe among females is 18 (example)
t.test(data$ahe[data$female==1],mu=18)

## Test the null that the true value of the mean of ahe among males in 1992 is 22 (example)
t.test(data$ahe[data$female==0 & data$year==1992],mu=22)


# B. COMPUTING CIs BY HAND, 90%, 95%, 99% CIs
# Compute the 95% CI for AHE by hand (example)
ahe_mu=mean(data$ahe)                 # Sample mean of ahe
ahe_nobs=length(data$ahe)             # Number of observations; length() returns the number of obs in ahe
ahe_sd=sd(data$ahe)                   # Sample standard deviation of ahe
ahe_se=ahe_sd/sqrt(ahe_nobs)          # Standard error of the sample mean
ahe_CI95_low=ahe_mu-1.96*ahe_se       # Lower bound of the 95% CI
ahe_CI95_high=ahe_mu+1.96*ahe_se      # Upper bound of the 95% CI

# Output CI results using 'paste' command for printing words and numbers on the same line
paste("95% CI Lower Bound:",ahe_CI95_low)
paste("95% CI Upper Bound:",ahe_CI95_high)

# Re-run t.test(data$ahe,mu=10) code to see 95% CI
# Confirm it is the same as what we computed by hand at [19.24,19.56]
t.test(data$ahe,mu=0)

# Computing 90% CI for ahe by hand
ahe_CI90_low=ahe_mu-1.65*ahe_se
ahe_CI90_high=ahe_mu+1.65*ahe_se

# Computing 99% CI for ahe by hand
ahe_CI90_low=ahe_mu-2.58*ahe_se
ahe_CI90_high=ahe_mu+2.58*ahe_se


# C. ONE-SIDED HYPOTHESIS TESTS
# We can also compute p-values for one-sided hypothesis tests by computing the 
# t-statistic by hand, and then using the CDF of the N(0,1) distribution

# p-value for one-sided hypothesis test that the mean of ahe is greater than 19.5
t_act=(ahe_mu-19.5)/ahe_se  # t-statistic
pvalue1=1-pnorm(t_act)      # compute p-value
paste("On-side p-value for greater than (>) alternative:",pvalue1)

# p-value for one-sided hypothesis test that the mean of ahe is less than 19.5
t_act=(ahe_mu-19.5)/ahe_se  # t-statistic
pvalue2=pnorm(t_act)        # compute p-value
paste("On-side p-value for less than (<) alternative:",pvalue2)


#**********************************************************************************************
# 5. TESTING DIFFERENCE IN MEANS FROM DIFFERENT POPULATIONS: t.test()

# We can also use the t.test() command to test the null that the difference of means from 
# two independent samples is 0. This is by far the most common two-sample t-test
# If we have two samples x and y, if we run t.test(x,y) it will test the null that the 
# different in means between x and y is d=0

## Test difference of means in ahe for female and male
# Remember, ahe[data$female==1]) is ahe for females, and ahe[data$female==0] is ahe for males
mean(data$ahe[data$female==1])
mean(data$ahe[data$female==0])
mean(data$ahe[data$female==1])-mean(data$ahe[data$female==0])   # Difference of sample means
t.test(data$ahe[data$female==1],data$ahe[data$female==0])       # T-test for difference of sample means is 0

## Test difference of means in ahe for bachelor and no bachelor
# Remember ahe[data$bachelor==1]) is ahe for bachelor degree, and ahe[data$bachelor==0] is ahe for 
# no bachelor degree
mean(data$ahe[data$bachelor==1])
mean(data$ahe[data$bachelor==0])
mean(data$ahe[data$bachelor==1])-mean(data$ahe[data$bachelor==0])   # Difference of sample means
t.test(data$ahe[data$bachelor==1],data$ahe[data$bachelor==0])       # T-test for difference of sample means is 0

## Test difference of means in ahe for male and female in 1992
# Gender wage gap in 1992
mean(data$ahe[data$female==1 & data$year==1992])
mean(data$ahe[data$female==0 & data$year==1992])
mean(data$ahe[data$female==1 & data$year==1992])-mean(data$ahe[data$female==0 & data$year==1992])  # Difference of sample means
t.test(data$ahe[data$female==1 & data$year==1992],data$ahe[data$female==0 & data$year==1992])        # T-test for difference of sample means is 0

## Test difference of means in ahe for male and female in 2012
# Gender wage gap in 2012
mean(data$ahe[data$female==1 & data$year==2012])
mean(data$ahe[data$female==0 & data$year==2012])
mean(data$ahe[data$female==1 & data$year==2012])-mean(data$ahe[data$female==0 & data$year==2012])  # Difference of sample means
t.test(data$ahe[data$female==1 & data$year==2012],data$ahe[data$female==0 & data$year==2012])      # T-test for difference of sample means is 0

## Test difference of means in ahe for bachelor and no bachelor in 1992
# Education wage gap in 1992
mean(data$ahe[data$bachelor==1 & data$year==1992])
mean(data$ahe[data$bachelor==0 & data$year==1992])
mean(data$ahe[data$bachelor==1 & data$year==1992])-mean(data$ahe[data$bachelor==0 & data$year==1992])  # Difference of sample means
t.test(data$ahe[data$bachelor==1 & data$year==1992],data$ahe[data$bachelor==0 & data$year==1992])      # T-test for difference of sample means is 0

## Test difference of means in ahe for bachelor and no bachelor in 2012
# Education wage gap in 2012
mean(data$ahe[data$bachelor==1 & data$year==2012])
mean(data$ahe[data$bachelor==0 & data$year==2012])
mean(data$ahe[data$bachelor==1 & data$year==2012])-mean(data$ahe[data$bachelor==0 & data$year==2012])  # Difference of sample means
t.test(data$ahe[data$bachelor==1 & data$year==2012],data$ahe[data$bachelor==0 & data$year==2012])      # T-test for difference of sample means is 0

## Test difference of means in ahe for male and female without bachelor in 2012
# Gender wage gap in 2012 among people without bachelor degree
mean(data$ahe[data$female==1 & data$year==2012 & data$bachelor==0])
mean(data$ahe[data$female==0 & data$year==2012 & data$bachelor==0])
diff1=mean(data$ahe[data$female==1 & data$year==2012 & data$bachelor==0])-mean(data$ahe[data$female==0 & data$year==2012 & data$bachelor==0])
paste("Difference in Mean Earnings in 2012 Between Males and Females without Bachelor Degrees:",diff1)
t.test(data$ahe[data$female==1 & data$year==2012 & data$bachelor==0],data$ahe[data$female==0 & data$year==2012 & data$bachelor==0])

## Test difference of means in ahe for male and female with bachelor in 2012
# Gender wage gap in 2012 among people with bachelor degree
mean(data$ahe[data$female==1 & data$year==2012 & data$bachelor==1])
mean(data$ahe[data$female==0 & data$year==2012 & data$bachelor==1])
diff2=mean(data$ahe[data$female==1 & data$year==2012 & data$bachelor==1])-mean(data$ahe[data$female==0 & data$year==2012 & data$bachelor==1])
paste("Difference in Mean Earnings in 2012 Between Males and Females with Bachelor Degrees:",diff2)
t.test(data$ahe[data$female==1 & data$year==2012 & data$bachelor==1],data$ahe[data$female==0 & data$year==2012 & data$bachelor==1])

# Graphically: difference in gender wage gap depending on education in 2012
pdf("ahe_female_bachelor_2012.pdf")
plot(density(data$ahe[data$female==1 & data$year==2012 & data$bachelor==0]), col="red",lty=1,main="Gender, Education, and Earnings in 2012", xlab="AHE")
lines(density(data$ahe[data$female==0 & data$year==2012 & data$bachelor==0]), col="blue",lty=1)
lines(density(data$ahe[data$female==1 & data$year==2012 & data$bachelor==1]), col="red",lty=2)
lines(density(data$ahe[data$female==0 & data$year==2012 & data$bachelor==1]), col="blue",lty=2)
legend("topright", legend=c("Female, No Degree", "Male, No Degree", "Female Degree", "Male Degree"), 
       col=c("red","blue","red","blue"), lty=c(1,1,2,2))
dev.off()


