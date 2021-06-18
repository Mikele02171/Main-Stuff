#**********************************************************************************************
# Tutorial 9 Code
# By: David Byrne
# Objectives: Joint Hypothesis Testing, Coefficient of Interest
#**********************************************************************************************


#**********************************************************************************************
# 1. SET WORKING DIRECTORY, LOAD PACKAGES

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial9")

## Load Applied Econometrics Package for heteroskedasticity robust standard errors
library(AER)


#**********************************************************************************************
# 2. LOAD DATA

## Load dataset on income and height
mydata1=read.csv(file="tute9_smoke.csv")

## List the variables in the dataset named mydata1
names(mydata1)

## Dimension of the dataset
# 3000 observations (babies and their mothers)
# 13 variables: id, birthweight, smoker, alcohol, drinks, nprevisit, tripre1, tripre2, tripre3,
#               tripre0, unmarried, educ, age, gambles          
dim(mydata1)


#**********************************************************************************************
# 3. JOINT MODEL TESTING: waldtest(), linearHypothesis()

# A. OVERALL MODEL F-STATISTIC

# The overall model F-statistics for the test of the joint null that are regression coefficients 
# are jointly equal to 0.

## Run main regression specification interest and print output
reg=lm(birthweight~smoker+alcohol+drinks+nprevisit+tripre1+tripre2+tripre3+unmarried+educ+age,data=mydata1)
coeftest(reg, vcov = vcovHC(reg, "HC1"))

# The waldtest() command, which is another name for the F-test, can be used to 
# compute the heteroskedasticity-robust overall F-statistic for a given regression
# Notice that with n=3000 observations and q=k=10 regressors, the degrees of freedom
# for this F-statistic are df1=10 and df2=3000-10-1=2989
## Compute the overall regression F-statistic for our regression
waldtest(reg, vcov = vcovHC(reg, "HC1"))

# Alternatively, you can use the linearHypothesis() command to compute the 
# heteroskedasticity-robust overall regression F-statistic by jointly testing
# that all the regression coefficients are 0. Here, we input all of the constraints into 
# the linearHypothesis() command in an intuitive way
## Compute the overall regression F-statistic for our regression (alternative method)
linearHypothesis(reg,c("smoker=0",
                       "alcohol=0",
                       "drinks=0",
                       "nprevisit=0",
                       "tripre1=0",
                       "tripre2=0",
                       "tripre3=0",
                       "unmarried=0",
                       "educ=0",
                       "age=0"),vcov = vcovHC(reg, "HC1"))

# Notice how both waldtest() and linearHypothesis yield identifcal F-statistics
# of F=23.88 and p-values<0.000001

# We can also compute the overall regression F-statistic for the regression
# using the summary() command, but this has the problem that it assumes homoskedasticity
## Compute the overall regression F-statistic for our regression (under homoskedasticity) 
summary(reg)

# Notice here how the F-statistic is larger at F=30.94. That is, once we correct for
# heteroskedasticity, we obtain a very differnt F-statistic, even though the outcome of the
# joint test is the same. This highlights the importance of accounting for 
# heteroskedasticity when computing F-statistics and conducting joint hypothesis tests


# B. HOMOSKEDASTICITY-ONLY F-STATISTIC

# Conduct homoskedasticity-only F-Statistic
# for the test tripre1=0, tripre2=0, tripre3=0

## Run the unrestricted regression and save the unrestricted R-Squared, assuming homoskedasticity
reg1=lm(birthweight~smoker+alcohol+drinks+nprevisit+tripre1+tripre2+tripre3+unmarried+educ+age,data=mydata1)
R2u=summary(reg1)$r.squared

## Run the restricted regression where the coefficients tripre1=0, tripre2=0, tripre3=0
## and save the restricted R-Squared, assuming homoskedasticity
reg2=lm(birthweight~smoker+alcohol+drinks+nprevisit+unmarried+educ+age,data=mydata1)
R2r=summary(reg2)$r.squared

## Compute the homoskedasticity-only F-statistic (df1=3, df2=3000-10-1=2989)
num1=(R2u-R2r)/3
denom1=(1-R2r)/2989
Fstat1=num1/denom1

## Compute p-value for Fstat using cumulative density function of F-distribution
## with df1=3, df2=2989 degrees of freedom; see tute3.R for CDF commands if needed
pval1=1-pf(Fstat1,df1=3,df2=2989)


# C. TESTING JOINT RESTRICTIONS

# We also use the linearHypothesis() commany to run joint hypothesis tests using a given regression model
# To conduct the test, we first estimate regression model using the lm() command: 
# reg=lm(yvar~xvar1+xvar2+...+xvark)
# Next, using our regression results in 'reg', we conduct the test as follows:
# linearHypothesis(reg,c("xvar1=a","xvar2=b")) 
# In this example, we would jointly test the coefficient on xvar1 equals a, and the 
# coefficient on xvar2 equals b
# The output from linearHypothesis() conains the F-statistic, p-value, degrees of freedom, residual sum of squares
# (RSS, which is the same as SSR in the lecture notes), among other thigns

## Jointly test coefficients on smoker=0 and alcohol=0
linearHypothesis(reg,c("smoker=0","alcohol=0"),vcov = vcovHC(reg, "HC1"))

## Jointly test coefficients on smoker=-200 and alcohol=-50
linearHypothesis(reg,c("smoker=-200","alcohol=-50"),vcov = vcovHC(reg, "HC1"))

## Jointly test coefficients on tripre1=0 and tripre2=0 and tripre3=0
linearHypothesis(reg,c("tripre1=0","tripre2=0","tripre3=0"),vcov = vcovHC(reg, "HC1"))

## Jointly test coefficients on tripre1=0 and tripre2=0
linearHypothesis(reg,c("tripre1=0","tripre2=0"),vcov = vcovHC(reg, "HC1"))

## Jointly test coefficients on tripre1=200 and tripre2=300 and tripre3=400
linearHypothesis(reg,c("tripre1=200","tripre2=300","tripre3=400"),vcov = vcovHC(reg, "HC1"))


# C. TESTING RESTRICTIONS WITH MULTIPLE PARAMETERS

# We can also use linearHypothesis() to test a single restriction involving
# multiple regression coefficients. For this, we run the command as
# linearHypothesis(reg,c("xvar1=xvar2")), which tests the null that the 
# regression coefficients on xvar1 and xvar2 in the regression are equal

## Re-run the main regression of interest for joint testing
reg=lm(birthweight~smoker+alcohol+drinks+nprevisit+tripre1+tripre2+tripre3+unmarried+educ+age,data=mydata1)
coeftest(reg, vcov = vcovHC(reg, "HC1"))

## Test regression coefficients on smoker and alcohol are equal
linearHypothesis(reg,c("smoker=alcohol"),vcov = vcovHC(reg, "HC1"))

## Test regression coefficient on smoker is twice as large as the regression coefficient on alcohol
linearHypothesis(reg,c("smoker=2*alcohol"),vcov = vcovHC(reg, "HC1"))

## Test sum of regression coefficients on smoker and alcohol equals -200
linearHypothesis(reg,c("smoker+alcohol=-200"),vcov = vcovHC(reg, "HC1"))

## Test sum of regression coefficients on alcohol and unmarried equals the coefficient on alcohol
linearHypothesis(reg,c("alcohol+unmarried=smoker"),vcov = vcovHC(reg, "HC1"))

## Test regression coefficient on tripre1, tripre2 and tripre3 are jointly equal to each other
linearHypothesis(reg,c("tripre1=tripre2","tripre2=tripre3"),vcov = vcovHC(reg, "HC1"))

## Test coefficient on tripre2 is twice the coefficient on tripe1 and that 
## the coefficient on tripe3 is twice the coefficient on tripe2
linearHypothesis(reg,c("tripre2=2*tripre1","tripre3=2*tripre2"),vcov = vcovHC(reg, "HC1"))


# D. TRANSFORMING THE REGRESSION TO CONDUCT A TEST INVOLVING MULTIPLE PARAMETERS

# Following a similar strategy to what is in the lecture notes, you can transform the regression
# to test the null that alcohol+unmarried=smoker. You can re-write the regression equation such that 
# you obtain a regression of the form: birthweight=b0 + g1 x smoker + b2 x W + b3 x Z + u 
# where W=alcohol+smoker and Z=unmarried+smoker, and where the a t-test for the null that the 
# regression coefficient on tripre1, g1, equals 0 is equivalent to testing the null that the 
# coefficients alcohol+unmarried=smoker the solutions provides the explicit calculations, 
# and the tutors will work through these in the tute.

## construct W
mydata1$W=mydata1$alcohol+mydata1$smoker

## construct Z
mydata1$Z=mydata1$unmarried+mydata1$smoker

## Re-run the transformed regression and conduct t-test
reg=lm(birthweight~smoker+W+Z+drinks+nprevisit+tripre1+tripre2+tripre3+educ+age,data=mydata1)
coeftest(reg, vcov = vcovHC(reg, "HC1"))

# Notice how the coefficient on smoker is 24.708, where you fail to reject the null with 
# a p-value of 0.8094. Notice this single-regressor hypothesis for the test of the null of the 
# coefficients alcohol+unmarried=smoker is identical to the p-value=0.8094 
# from the joint-test of this null:
reg=lm(birthweight~smoker+alcohol+drinks+nprevisit+tripre1+tripre2+tripre3+unmarried+educ+age,data=mydata1)
linearHypothesis(reg,c("alcohol+unmarried=smoker"),vcov = vcovHC(reg, "HC1"))



