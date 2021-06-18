#**********************************************************************************************
# Tutorial 6 Code
# By: David Byrne
# Objectives: Single Linear Regression Testing
#**********************************************************************************************


#**********************************************************************************************
# 1. SET WORKING DIRECTORY

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial6")


#**********************************************************************************************
# 2. REGRESSION: HEIGHT AND EARNINGS: lm(), confint(), coef()

# A. LOAD DATA

## Load dataset on income and height
mydata1=read.csv(file="tute6_height.csv")

## List the variables in the dataset named mydata1
names(mydata1)

## Dimension of the dataset
# 17870 observations (workers)
# 6 variables: id, earnings, height, weight, sex, age
dim(mydata1)


# B. REGRESSIONS AND CONFIDENCE INTERVALS

# Regression output using the linear model lm() function reports OLS regression coefficient
# standard errors, t-statistics ("t-value"), and p-value (P(>|t|)) for the 2-sided hypothesis
# test that the OLS slope coefficient or estimate is equal to 0
# with stars indicating statistical significance at various levels of significance, 
# in particular <0.001, 0.001, 0.01, 0.05, 0.1

## Regression of earnings on height
earn_reg1=lm(earnings~height,data=mydata1)
summary(earn_reg1)

# 2.A Confidence Intervals

# We can also compute confidence intervals (CIs) after estimating an OLS model with lm() with the
# confint() command. The command has the following structure: confint(reg,xvar,level=X) where
  # 'reg' is the regression you want to compute the CI based on
  # 'xvar' is the independent variable in the regression you want to compute the CI for
  # 'level=X' is the level of confidence you want to specific

## 95% CI for the OLS slope coefficient on height from earn_reg1 regression
confint(earn_reg1, 'height', level=0.95)

## 90% CI for the OLS slope coefficient on height from earn_reg1 regression
confint(earn_reg1, 'height', level=0.90)

## 99% CI for the OLS slope coefficient on height from earn_reg1 regression
confint(earn_reg1, 'height', level=0.99)

## 95% CI for the OLS intercept from earn_reg1 regression
confint(earn_reg1, '(Intercept)', level=0.95)


# 2.B Confidence Intervals by Hand

# 95% CI for the OLS slope coefficient computed by hand
# To do this, we first need to get the regression coefficients
# from our earn_reg1 regression. We do this using the coef() command

## Obtain regression coefficients from earn_reg1 regression
beta=coef(summary(earn_reg1))[, "Estimate"] 
# beta[1] is OLS estimate of intercept
# beta[2] is OLS estimate of slope

## Obtain standard errors from coefficients earn_reg1 regression
se=coef(summary(earn_reg1))[, "Std. Error"] 
# se[1] is standard error of OLS estimate of intercept
# se[2] is standard error of OLS estimate of slope

## Compute 95% CI of the regression slope coefficient by hand
CI95_low=beta[2]-1.96*se[2]    # lower bound of 95% CI
CI95_upp=beta[2]+1.96*se[2]    # upper bound of 95% CI
# Compare CI95_low and CI95_upp to the output from confint(earn_reg1, 'height', level=0.95)
# and verify the numbers are close (they differ because -1.96/1.96 is an approximation to 
# the exact 2.5 and 97.5 percentiles of the N(0,1) distribution)


# 2.C Alternative Confidence Intervals for Various Changes in the Independent Variable

# Alternative CI for change
# A useful feature of having computed the CI by hand is we can easily compute the CI now 
# for the impact of different changes in height on earnings, and not just one-unit changes
# which is what RStudio provides by default

## 95% CI for increasing height by 100cm on earnings
CI95_low_100=100*(beta[2]-1.96*se[2])    # lower bound of 95% CI
CI95_upp_100=100*(beta[2]+1.96*se[2])    # upper bound of 95% CI
paste("95% CI lower bound for 100cm increase in earnings is: ", CI95_low_100)
paste("95% CI upper bound for 100cm increase in earnings is: ", CI95_upp_100)

# 2.D Alternative Hypothesis Tests

# Another useful feature of having retrieved our OLS regression estimates and standard errors
# using the coef() command above is we can also easily compute t-statistics for alternative
# hypothesis tests, and not just hypothesis tests of the null that a coefficient equals 0,
# which is what RStudio (and virtually all programs) do as a default

## t-statistic and p-value for null that slope=0.05
tstat1=(beta[2]-0.05)/se[2]
pval1=2*pnorm(-abs(tstat1))
paste("pvalue for 2-sided test of null that slope=0.05 is:", pval1)
# Reject null, p-value (pval1) <0.000001

## t-statistic and p-value for null that slope=0.03
tstat2=(beta[2]-0.03)/se[2]
pval2=2*pnorm(-abs(tstat2))
paste("pvalue for 2-sided test of null that slope=0.03 is:", pval2)
# Fail to reject null, p-value (pval2)=0.280


#**********************************************************************************************
# 2. REGRESSION: HOMICIDES AND POLICE

# A. LOAD DATA
## Load dataset on income and height
mydata2=read.csv(file="tute6_crime.csv")


# B. DESCRIPTIVES

## Summary Statistics
summary(mydata2)
# So a typical county had 3066 police offices and 13 homicides in 2012
# The range is considerable: min police and homicides is 809 and 1
# The max police and homicides is 31435 and 111 (!)

## Scatter plot of homicides and police numbers
pdf("q2_scat_homicides_police1.pdf")
plot(mydata2$police,mydata2$homicides,
     main="Homicides and Police Force Across England and Wales Counties",
     xlab="Number of Police Officers in 2012",
     ylab="Number of Homicides in 2012",
     col="forestgreen",
     pch=16)
dev.off()

# The first scatter plot highlights potential outlier with more than 100 homicides
# and more than 30000 police in the 'Metropolitan Police' county, which is London
# The key question here is whether London should be included in the analysis with 
# all the other counties which are far less populous. 

## Scatter plot removing potential outlier
pdf("q2_scat_homicides_police2.pdf")
plot(mydata2$police[mydata2$homicides<100],mydata2$homicides[mydata2$homicides<100],
     main="Homicides and Police Force Across England and Wales Counties",
     sub="(Outlier Removed)",
     xlab="Number of Police Officers in 2012",
     ylab="Number of Homicides in 2012",
     col="forestgreen",
     pch=16)
dev.off()


# C. REGRESSIONS AND VARIABLE SCALING

# C.1 Variable Scaling

## Single Linear Regression of Homocides and Police with 95% Confidence Interval
crime_reg1=lm(homicides~police, data=mydata2)
summary(crime_reg1)
confint(crime_reg1, 'police', level=0.95)

# Notice in the first regression crime_reg1 that the OLS slope coefficient estimate is 0.0035662
# The interpretation of this is increasing the number of police officers by 1 has a corresponding 
# increase in number of homicides of 0.003 that is statistically significant at the 1% level
# While this interpretation and inference is valid, it is somewhat useless
# The reason for this is the scaling of the OLS estimate is poor. More specifically,
# the number of 0's after the decimal and preceding the first decimal of interest (3) is an example
# of poor scaling of the independent variable, police. The scaling problem also affects the 95% CI. 
# The reason this scaling problem occurs is the number police officers is in the 1000's while
# the number of homicides are almost all less than 100
# So the very small regression coefficientof 0.0035662 in the crime_reg1 results reflects the 
# difference in the scale of the dependent and independent variables

# To generate more economically meaningful results, it is helpful to construct a re-scaled 
# independent variable, police, in terms of 1000's of policy. Re-scalling in this way allows
# the dependent and independent variable to have the same scale. 

## Construct re-scalled police independent variable in terms of 1000's of police
mydata2$police_1000=mydata2$police/1000     # save the re-scaled police variable in mydata2
summary(mydata2)
# Notice how with the summary statistics police_1000 now shows up with a mean of 
# 3.066 (which means 3066 police on average) which has a similar scale as the mean 
# of homicides in the sample of 12.93

## Re-run our homicides and police regression with our re-scaled police_1000 regressor
## and compute the 95% confidence interval
crime_reg2=lm(homicides~police_1000, data=mydata2)
summary(crime_reg2)
confint(crime_reg2, 'police_1000', level=0.95)
# Notice how now our OLS regression coefficient estiamte is now 3.5662 which has the 
# interpretation if you increase the number of police officers by 1000 there is a 
# corresponding statistically significant 3.5662 (or just 3.57) increase in the number of homicides, 
# which is a much easier set of results to interpret without scaling problems. The results are
# identical to the unscaled results, but are much more effective for interpretation

# As a general rule, always re-scale variables if needed to avoid having many leading
# or trailing zeros. Aim to have a most one trailing 0 before the decimal or one
# leading zero after the 0 in all of your regression results. So regression coefficients
# like 3000, 300, 0.003, or 0.0003 typically suffer from scaling problems, while coefficients
# like 30, 3, 0.3 or 0.03 do not typically have scaling problems


# C.2 Outliers

# Recall from our scatter plot above "q2_scat_homicides_police1.pdf" that 'Metropolitan Police'
# is a potential outlier. Let's look at the influence of the outlier on our results using 
# re-scaled police numbers throughout

## Regression results without potential outlier
crime_reg3=lm(homicides[homicides<100]~police_1000[homicides<100], data=mydata2)
summary(crime_reg3)
confint(crime_reg3, 'police_1000[homicides < 100]', level=0.95)
# We still obtain a statistically significant impact at the 1% level which has the 
# interpretation that increasing the number of police officers by 1000 has a corresponding
# 4.47 increase in the number of homicides, which compares to our original estimate of 3.57 
# above. Quantitatively, this is large increase in the OLS regression coefficient. In particular,
# removing the outlier increases the magnitude of the OLS regression coefficient estimate
# by 100 x (4.47-3.57)/3.57 = 25.2%, which is a large magnitude difference. We should 
# drop the London-based outlier given this large change.

# We can visualise the change in the regression results by plotting our scatter plot
# for police officers and homicides and our predicted regression lines for our
# crime_reg2 and crime_reg3 results. Notice that the scatter plot is now based on the 
# scaled number of police officers in 1000's variable, police_1000.

## Plotting the impact of the oulier on regression results, highlighting the outlier's impact
pdf("q2_scat_homicides_police3.pdf")
plot(mydata2$police_1000,mydata2$homicides,
     main="Homicides and Police Force Across England and Wales Counties",
     xlab="Number of Police Officers in 2012 (1000s)",
     ylab="Number of Homicides in 2012",
     col="forestgreen",
     pch=16)
abline(crime_reg2, col="blue", lwd=2)
abline(crime_reg3, col="red", lwd=2)
dev.off()

