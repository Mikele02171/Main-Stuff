#**********************************************************************************************
# Tutorial 5 Code
# By: David Byrne
# Objectives: Single Linear Regression Estimation
#**********************************************************************************************


#**********************************************************************************************
# 1. SET WORKING DIRECTORY

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial5")


#**********************************************************************************************
# 2. REGRESSIONS in R: cor(), lm(), abline()

# Example #1: Income and Height (micro data)

# A. LOAD DATA
# We label the first dataset "data1" to distinguish it from the second dataset in
# the tute which we (later) label "data2". We discuss this further below.

## Load dataset on income and height
data1=read.csv(file="tute5_height.csv")

## List the variables in the dataset named data1
names(data1)

## Dimension of the dataset
# 17870 observations (workers)
# 6 variables: id, earnings, height, weight, sex, age
dim(data1)


# B. DESCRIPTIVES, CORRELATION, SCATTERPLOT: cor()

## Summary Statistics
summary(data1)

## Sample correlation between height and earnings using the cor() function
cor(data1$height,data1$earnings)

## Scatter plot visualising the relationship between height and earnings 
pdf("q1_scat_height_earnings.pdf")
plot(data1$height,data1$earnings,
     main="Relationship Between Height and Earnings",
     xlab="Height in Centimeters",
     ylab="Annual Earnings in $10,000's",
     col="blue",
     pch=16)
dev.off()


# C. TESTS OF SAMPLE MEANS

# Compare sample means for people with height above the median height of 170cm
# and below the median height of 170cm. This provides an initial indication
# of whether the top 50% of people in terms of height earn more or less than the
# bottom 50% of people in terms of height

## Mean earnings for heights above and below 170cm
mean(data1$earnings[data1$height>=170])
mean(data1$earnings[data1$height<170])

## Difference in means for people taller and shorter than 170cm
mean(data1$earnings[data1$height>=170])-mean(data1$earnings[data1$height<170])

## 2-sample t-test of difference in means for people taller and shorter than 170cm 
t.test(data1$earnings[data1$height>=170],data1$earnings[data1$height<170])


# D. ESTIMATE SIMPLE LINEAR REGRESSION: lm()

# The lm() command stands for "linear model" and it is the command for running
# linear regressions in R. For single linear regressions, the code is run as
# output=lm(yvariable~xvariable,data=dataset) where
  # output: stores the output from running the linear regression
  # yvariable: is the dependent variable of the regression
  # xvariable: is the independent variable of the regression
  # data=dataset: specifies the dataset where yvariable and xvariable can be found

# To run the single linear regression of interest of earnings on height using data
# from the dataset data1 we can use the lm() command and one the line that follows
# use the summary command to display the output from the regression

## Single linear regression of earnings on height
earn_reg1=lm(earnings~height,data=data1)
summary(earn_reg1)
sd(data1$height)

# In this example, we save the regression results in "earn_reg1" and then use 
# summary(earn_reg1) to print the regression output. The output includes
  # Intercept and slope coefficient estimate, standard error, t-statistic ("t-value") and p-values
  # Statistical significance codes/markers for levels of significance of <0.001, 0.001, 0.01, 0.05, 0.1
  # Standard Error of the Regression ("Residual standard error")
  # R-Squared ("Multiple R-Squared)
  # Adjusted R-Squared (we will return to this lecture note 6 on multiple linear regression)
  # F-statistic for the regression (we will return to this lecture note 6 on multiple linear regression)


# E. REGRESSIONS USING SUBSETS OF DATA

# We can also run regressions subsets of data using the indexing commands 
# that allow us to examine subsets of data from tute 4. 

## Single linear regression of earnings on height among males
earn_reg2=lm(earnings[male==1]~height[male==1],data=data1)
summary(earn_reg2)

## Single linear regression of earnings on height among females
earn_reg3=lm(earnings[male==0]~height[male==0],data=data1)
summary(earn_reg3)

# By comparing the results in earn_reg2 and earn_reg3, we can see whether
# the relationship between earnings and height is difference between males and females, for example.


#**********************************************************************************************
# 3. REGRESSIONS in R

# Example #2: International Trade and Growth (Macro data)

# A. LOAD DATA
# Recall we are labelling our second dataset data2 to distinguish it from data1 on 
# earnings and height. After loading data2, look at your Environment window to the right 
# of your R-Studio screen and you will see data1 and data2 separately loaded. A nice
# feature of R is you can have multiple datasets loaded at the same time, and you can work
# on them separately or together

## Load dataset
data2=read.csv(file="tute5_growth.csv")

## List the variables in the dataset named data
names(data2)

## Dimension of the dataset
# 65 observations (countries)
# 6 variables: country, GDP growth, 1960 real GDP, trade share
dim(data2)


# B. DESCRIPTIVES, CORRELATION, SCATTERPLOT
summary(data2)
sd(data2$tradeshare)

cor(data2$tradeshare,data2$growth)
pdf("q2_scat_trade_growth1.pdf")
plot(data2$tradeshare,data2$growth,
     main="Trade Share of GDP and Economic Growth",
     xlab="Average share of trade in the economy from 1960 to 1995 (X+M)/GDP",
     ylab="Average Annual Percentage Growth of Real GDP from 1960 to 1995",
     col="red",
     pch=16)
dev.off()

## Correlation and scatterplot without potential outlier (Malta)
cor(data2$tradeshare[data2$tradeshare<max(data2$tradeshare)],data2$growth[data2$tradeshare<max(data2$tradeshare)])
pdf("q2_scat_trade_growth2.pdf")
plot(data2$tradeshare[data2$tradeshare<max(data2$tradeshare)],data2$growth[data2$tradeshare<max(data2$tradeshare)],
     main="Trade Share of GDP and Economic Growth",
     xlab="Average share of trade in the economy from 1960 to 1995 (X+M)/GDP",
     ylab="Average Annual Percentage Growth of Real GDP from 1960 to 1995",
     col="red",
     pch=16)
dev.off()



# C. ESTIMATE SIMPLE LINEAR REGRESSION, COMBINING SCATTER PLOTS AND REGRESSIONS: abline()

## Regression of growth on tradeshare for entire dataset
growth_reg1=lm(growth~tradeshare,data=data2)
summary(growth_reg1)

## Regression of growth on tradeshare exclusing potential outlier (Malta)
growth_reg2=lm(growth[tradeshare<max(tradeshare)]~tradeshare[tradeshare<max(tradeshare)],data=data2)
summary(growth_reg2)

# You use your regression output name and the command abline() to add the regression line to a 
# scatter plot to visualize how the scatter plot relates to the regression results
## Scatter plot of tradeshare and growth including results from regression 1 for entire sample
pdf("q2_scat_trade_growth3.pdf")
plot(data2$tradeshare,data2$growth,
     main="Trade Share of GDP and Economic Growth",
     xlab="Average share of trade in the economy from 1960 to 1995 (X+M)/GDP",
     ylab="Average Annual Percentage Growth of Real GDP from 1960 to 1995",
     col="red",
     pch=16)
abline(growth_reg1, col="forestgreen", lwd=2)
dev.off()

## Scatter plot of tradeshare and growth including results from regression 2 for entire sample
## except potential outlier (Malta)
pdf("q2_scat_trade_growth4.pdf")
plot(data2$tradeshare[data2$tradeshare<max(data2$tradeshare)],data2$growth[data2$tradeshare<max(data2$tradeshare)],
     main="Trade Share of GDP and Economic Growth",
     xlab="Average share of trade in the economy from 1960 to 1995 (X+M)/GDP",
     ylab="Average Annual Percentage Growth of Real GDP from 1960 to 1995",
     col="red",
     pch=16)
abline(growth_reg2, col="blue", lwd=2)
dev.off()
