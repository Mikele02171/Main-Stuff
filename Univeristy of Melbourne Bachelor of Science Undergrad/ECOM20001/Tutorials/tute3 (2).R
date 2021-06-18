#**********************************************************************************************
# Tutorial 3 Code
# By: David Byrne
# Objectives: Distributions in R, LLN and CLT
#**********************************************************************************************


#**********************************************************************************************
# 1. SET WORKING DIRECTORY AND LOAD DATA

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial3")


#**********************************************************************************************
# 2. DISTRIBUTIONS IN R: dnorm(), pnorm(), qnorm(), rnorm(), set.seed(), dchisq(), pchisq(), 
#                        qchisq(), rchisq(), dt(), pt(), qt(), rt(), df(), pf(), qf(), rf(),

# R has commands for computing probability densitie (PDF)s, cumulative densities (CDF), and 
# generating random numbers from a user-specified distribution. Here we show you how to study
# the Normal, Chi-Square, Student-t, and F-Distribution

# A. NORMAL DISTRIBUTION: dnorm(), pnorm(), qnorm(), rnorm(), set.seed()
# You can experiment with other Normal distributions if you like by changing the mean and sd
# values. We focus on the N(0,1) distribution because we rely on it heavily throughout the 
# subject

## N(0,1) PDF evaluated at -2.58, -1.96, -1.65, 1, 1.65, 1.96, 2.58
dnorm(-2.58,mean=0,sd=1)
dnorm(-1.96,mean=0,sd=1)
dnorm(-1.65,mean=0,sd=1)
dnorm(0,mean=0,sd=1)
dnorm(1.65,mean=0,sd=1)
dnorm(1.96,mean=0,sd=1)
dnorm(2.58,mean=0,sd=1)

## N(0,1) CDF evaluated at -2.58, -1.96, -1.65, 1, 1.65, 1.96, 2.58
pnorm(-2.58,mean=0,sd=1)
pnorm(-1.96,mean=0,sd=1)
pnorm(-1.65,mean=0,sd=1)
pnorm(0,mean=0,sd=1)
pnorm(1.65,mean=0,sd=1)
pnorm(1.96,mean=0,sd=1)
pnorm(2.58,mean=0,sd=1)

## N(0,1) quantile function for 0.005, 0.025, 0.05, 0.50, 0.95, 0.975, 0.995
qnorm(0.005,mean=0,sd=1)
qnorm(0.025,mean=0,sd=1)
qnorm(0.05,mean=0,sd=1)
qnorm(0.50,mean=0,sd=1)
qnorm(0.95,mean=0,sd=1)
qnorm(0.975,mean=0,sd=1)
qnorm(0.995,mean=0,sd=1)
# The quantile function takes an argument p between 0 and 1 and returns the 
# a value x such that the CDF of the normal distribution evaluated at x is p

# Generating normal random variables
# R can generate datasets of normal random variables, but relies on a "seed"
# to do this. The seed basically gets R's normal random number generator 
# initiated, and allows you to replicate your normal random numbers if 
# whenever you re-run your R code. If you do not set the seed, the R
# will generate complete random numbers and you will not be able to 
# produce the same random numbers each time you run your code for your 
# analyses. So it is always a good idea to "set the seed" before you
# start generating random numbers. 

## Setting the seed with a user-specified seed value, here we have 2904 
## as the seed value
set.seed(2904)

## Generate nobs=1000 N(0,1) random numbers and save them in a variable called x1
nobs=1000
x1=rnorm(nobs,mean=0,sd=1)

## Plot your 1000 N(0,1) random numbers, or view them with View(x1)
pdf("pdf_normal.pdf")
plot(density(x1), main="N(0,1) Distribution") 
dev.off()


# As an exercise, try highlighting all the code above and clicking the 
# run button a few times. You will see the same random values for x appear each time
# Then comment out the set.seed() line above, highlight all the code, and run it again
# and you will see the x values randomly change everytime without the seed set


# B. Chi-Square, Student-t, F-Distribution: dchisq(), pchisq(), qchisq(), rchisq(), 
# dt(), pt(), qt(), rt(), df(), pf(), qf(), rf(),
# Similar commands for the PDF, CDF, quantile function, and random number generators
# exist for the other three key distributions we use in the subject

## Chi-Square Distribution with df=3 degrees of freedom, plot PDF for 1000 draws
dchisq(7,df=3)     # PDF evaluated at 7
pchisq(7,df=3)     # CDF evaluated at 7
qchisq(0.95,df=3)  # Quantile funciton evaluated at probability p=0.95
x2=rchisq(nobs,df=3)
pdf("pdf_chisq.pdf")
plot(density(x2), main="ChiSq(12) Distribution") 
dev.off()

## Student-t Distribution with df=26 degrees of freedom, plot PDF for 1000 draws
dt(3,df=26)         # PDF evaluated at 3
pt(3,df=26)         # CDF evaluated at 3
qt(0.025,df=26)     # Quantile funciton evaluated at probability p=0.025
x3=rt(nobs,df=26)
pdf("pdf_t.pdf")
plot(density(x3), main="t(26) Distribution") 
dev.off()

## F Distribution with df1=5, df2=2 degrees of freedom
df(1,df1=5,df2=2)     # PDF evaluated at 1
pf(1,df1=5,df2=2)     # CDF evaluated at 1
qf(0.95,df1=5,df2=2)  # Quantile funciton evaluated at probability p=0.95
x4=rf(nobs,df1=5,df2=2)
x4=x4[x4<20]          # Dropping x4 values bigger than 20 to make the graph nicer
pdf("pdf_f.pdf")
plot(density(x4), main="f(5,2) Distribution") 
dev.off()


#**********************************************************************************************
# 3. LAW OF LARGE NUMBERS (LLN) AND CENTRAL LIMIT THEOREM (CLT)
# In this section we run calculations to show how the LLN and CLT works

# Suppose we draw a random sample of nobs=1000 x's from a population, where the underlying 
# population of data corresponds to a Chi-Square distribution with df=3 degrees of freedom
# This implies from the density for the x's that the sample has a distribution that is 
# skewed to the right

# A. GENERATING DISTRIBUTIONS OF SAMPLE MEANS

## Generate a nobs=1000 sample of x's from a Chi-Square distribution with df=3, 
## and compute the mean
nobs=1000
x=rchisq(nobs,df=3)
plot(density(x), main="Chi-Square df=3, nobs=1000") 
x_mean=mean(x) 
print("First mean")
print(x_mean)

## Do it again: generate a nobs=1000 sample of x's from a Chi-Square distribution with df=3, 
## and compute the mean
x=rchisq(nobs,df=3)
plot(density(x), main="Chi-Square df=3, nobs=1000") 
x_mean=mean(x) 
print("Second mean")
print(x_mean)

## Do one more time: generate a nobs=100 sample of x's from a Chi-Square distribution with df=3, 
## and compute the mean
x=rchisq(nobs,df=3)
plot(density(x), main="Chi-Square df=3, nobs=1000") 
x_mean=mean(x) 
print("Third mean")
print(x_mean)

# Notice how the distributions and means all differ sample-by-sample, but they are similar
# Now suppose we were to repeat this K=500 times. Each time we randomly draw samples of x's 
# with nobs=1000 from a Chi-Square distribution with df=3, and then compute the mean for each sample
# So in the end, we will have compute K=500 sample means when we are done
# The following code does this

## Specify sample size nobs, df, K
# Note: for the tutorial, you will try nobs=10, nobs=50, nobs=100, nobs=1000 
# and compare the results in presenting the LLN and CLT

# ***** ALTER FOR ASSIGNMENT HERE *****
nobs=1000   # alter nobs for the assignment re-run the code from this line to the bottom
df=3
K=500

## Creates a variable called "means" with K=500 rows for saving the 500 means
means=matrix(0,K,1)
# run "View(means)" to look at your means

## Draw K=500 random samples each with nobs=100 observations from a Chi-Square distribution with
## df=3, and save the mean from each sample
# Note: you are not responsible for knowing how to use loops or matrix operations in ECOM20001. 
# We are just  doing it here to illustrate how the LLN and CLT works
for (k in 1:K){
  x=rchisq(nobs,df=3) # draw the sample
  means[k]=mean(x)    # save the mean
}
# After running the above code, you will have K=500 means stored in the variable "means" 


# B. LAW OF LARGE NUMBERS
# As a point of reference, the Chi-Square distribution has an E[x]=df, that is, the expected
# value is simply the degrees of freedom of the distribution
# So the true value of the mean is truevalue=df, which is 3 in our example

## Compute true value
truevalue=df

# Recall from lectures that the LLN says that the sample average will be more
# likely to be close to the true value of the meanas n becomes large
# To illustrate this, let's compute the percentage of the K=500 sample averages in the means
# variable that are with 0.3 of the true value of 3, that is the number of sample averages 
# that lie between 2.7 and 3.3

## Compute absolute value of the error between sample averages and true value
err=abs(means-truevalue)

# Let's say a sample average is "close" to the true value if it is within 0.3 of the true value
# You could choose any error rule (e.g 1%, 5%) for illustrating the LLN
# Note: we are again using vector commands here for convenience; 
# you are not responsible for vector commands for ECOM20001

## Compute percentage of sample averages within 0.3 (or 10%) of the true value;
pct=100*sum(err<0.3)/K

## Compute variance of the K=500 sample averages with var()
varmeans=var(means)

## Print LLN results
print("Number of observations in each random sample")
print(nobs)
print("Percentage of Sample Averages within 0.3 of the True Value")
print(pct)
print("Variance of the K=500 Sample Means")
print(varmeans)

# By alterning nobs above at the "ALTER FOR ASSIGNMENT HERE" point, you should
# obtain approximately the following values for pct and varmeans for each nobs value
# (but your pct and varmeans values will differ somewhat because of the random number generator)
# nobs=10, pct=30, varmeans=0.60
# nobs=50, pct=65, varmeans=0.12
# nobs=100, pct=80, varmeans=0.06
# nobs=1000, pct=100, varmeans=0.006

# The LLN is illustrated here: as nobs increases, the fraction of sample means
# that you compute from random sampling are more likely to be close 
# (e.g., within 0.3 as our "close" rule) to the true value of the mean

# Relatedly, the LLN is illustrated by the fact that varmeans falls as nobs rises
# Implies: as sample sizes get larger, we get more precise estimates of the underlying
# population true value of the mean from the sample average. In other words, a given 
# sample average is more likely to be close to the true mean value as nobs rises


# C. CENTRAL LIMIT THEOREM
# The CLT states that under i.i.d random sampling, the distribution of sample means
# coverges to a normal distribution centered around the population true value of the mean
# So as nobs grows, the distribution of the K=500 sample means will increasingly look like
# a normal distribution. 

# Separately, notice how that even though the underlying samples are generated by a 
# Chi-Square distribution with df=3 which is right-skewed, the corresponding distribution
# of the sample mean is still symmetrically distributed as a normal distribution
# That is, the skeweness of the underlying sampling distributions is irrelevant for the CLT
# as the distribution of the sample average will converge to a symmetric normal distribution 
# as the sample size nobs grows

## Plot the distribution of sample means (change this line to save different file names)
pdf("means_nobs_1000.pdf")    
plot(density(means), main="Distribution of Sample Means, n=1000", xlim = c(0, 6)) 
dev.off()

# Note: you will want to give this a different name when you plot the distribution of 
# the sample mean for different values of nobs=10, 50, 100, 1000 for the assignment
# Consider using means_nobs_10.pdf, means_nobs_50.pdf, means_nobs_100.pdf, means_nobs_1000.pdf


