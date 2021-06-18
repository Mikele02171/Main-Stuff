#**********************************************************************************************
# Tutorial 11 Code
# By: David Byrne
# Objectives: Logarithmic Regression and Interactions
#**********************************************************************************************


#**********************************************************************************************
# 1. SET WORKING DIRECTORY, LOAD DATA AND PACKAGES

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial11")

## Load Applied Econometrics Package for heteroskedasticity robust standard errors
library(AER)

## Load Stargazer package for regression tables
library(stargazer)

## Load dataset on income and height
mydata1=read.csv(file="tute11_cps.csv")

## List the variables in the dataset named mydata1
names(mydata1)

## Dimension of the dataset
# 15052 observations (individuals)
# 5 variables: year, ahe, bachelor, female, age
dim(mydata1)


#**********************************************************************************************
# 2. LOGARITHMIC REGRESSIONS: as.numeric()

## Create logarthimic variables for ahe and age
mydata1$log_ahe=log(mydata1$ahe)
mydata1$log_age=log(mydata1$age)

# The as.numeric() command can be used to create dummy variables in R
## Create year of sample dummy variables for the regression
mydata1$d1992=as.numeric(mydata1$year==1992)  #d1992 is a dummy variable that equals one if year=1992, and 0 otherwise
mydata1$d2012=as.numeric(mydata1$year==2012)  #d2012 is a dummy variable that equals one if year=2012, and 0 otherwise

## Regression of ahe on age + controls
reg1=lm(ahe~age+bachelor+female+d1992,data=mydata1)
cov1=vcovHC(reg1, type = "HC1")    
se1=sqrt(diag(cov1))

## Regression of ahe on log(age) + controls
reg2=lm(ahe~log_age+bachelor+female+d1992,data=mydata1)
cov2=vcovHC(reg2, type = "HC1")    
se2=sqrt(diag(cov2))

## Regression of log(ahe) on age + controls
reg3=lm(log_ahe~age+bachelor+female+d1992,data=mydata1)
cov3=vcovHC(reg3, type = "HC1")    
se3=sqrt(diag(cov3))

## Regression of log(ahe) on log(age) + controls
reg4=lm(log_ahe~log_age+bachelor+female+d1992,data=mydata1)
cov4=vcovHC(reg4, type = "HC1")    
se4=sqrt(diag(cov4))

## Regression output table
# Discuss the results from stargazer() as asked in the question on the assignment sheet.
stargazer(reg1, reg2, reg3, reg4, type="text",
          se=list(se1, se2, se3, se4),
          digits=3, 
          dep.var.labels=c("AHE","Log(AHE)"),
          covariate.labels=
            c("Age",
              "Log(Age)",
              "Bachelor Degree",
              "Female",
              "1992 Dummy",
              "Constant"),
          out="reg_output1.txt")   # Output results to your director in a text file


#**********************************************************************************************
# 3. INTERACTIONS REGRESSIONS

# A. CREATE INTERACTIONS

## Create interactive variables involving female, age, and bachelor
mydata1$female_age=mydata1$female*mydata1$age
mydata1$female_bachelor=mydata1$female*mydata1$bachelor


# B. RUN INTERACTIVE REGRESSIONS

## Regression of ahe on age, allowing for differential gender effects with age, + controls
reg5=lm(ahe~age+bachelor+female+female_age+d1992,data=mydata1)
cov5=vcovHC(reg5, type = "HC1")    
se5=sqrt(diag(cov5))

## Regression of ahe on age, allowing for differential gender effects with bachelor, + controls
reg6=lm(ahe~age+bachelor+female+female_bachelor+d1992,data=mydata1)
cov6=vcovHC(reg6, type = "HC1")    
se6=sqrt(diag(cov6))

## Regression output table
# Discuss the results from stargazer() as asked in the question on the assignment sheet.
stargazer(reg5, reg6, type="text",
          se=list(se5, se6),
          digits=3, 
          dep.var.labels=c("AHE"),
          covariate.labels=
            c("Age",
              "Bachelor Degree",
              "Female",
              "Female x Age",
              "Female x Bachelor",
              "1992 Dummy",
              "Constant"),
          out="reg_output2.txt")   # Output results to your director in a text file



# C. COMPUTE PARTIAL EFFECTS AND THEIR CONFIDENCE INTERVALS

# Note: the default here is to computing the partial effect of being female at age=28 and its standard error
# To compute the partial effect of being female at other age=XX, change age=XX and female_age=XX on line 96 and re-run 
# the code between lines 96 and 128

## Data frame for female aged 28, predicted value for ahe for female aged 28 based on reg7, other variables (bachelor, d1992) irrelevant
newdata1=data.frame(age=28,bachelor=1,female=1,female_age=28,d1992=0)
ahe1=predict(reg5, newdata=newdata1)

## Data frame for male aged 28, predicted value for ahe for male aged 28 bsaed on reg7, other variables (bachelor, d1992)  irrelevant
## (all female variables and interactions are 0 in this dataframe)
newdata2=data.frame(age=28,bachelor=1,female=0,female_age=0,d1992=0)
ahe2=predict(reg5, newdata=newdata2)

## Partial effect of being female at age 28
dahe=ahe1-ahe2

## Fstatistic for Test of Difference in ahe if female=1 or female=0
Ftest=linearHypothesis(reg5,c("female+28*female_age=0"),vcov = vcovHC(reg5, "HC1"))

## Recover the Fstat from the joint test results in Ftest
Fstat=Ftest[2,3]
sprintf("Fstat %f", Fstat)

## Compute the standard error for the partial effect we computed, dahe (see slide 21 of Lecture note 8) 
se_dahe=abs(dahe)/sqrt(Fstat)

## 95% CI for the partial effect we computed, dahe
dahe_ci95L=dahe-se_dahe*1.96
dahe_ci95H=dahe+se_dahe*1.96

## Outputting results
sprintf("partial effect of age for females: %f", dahe)
sprintf("SE of partial effect of age for females: %f", se_dahe)
sprintf("95 CI lower bound for partial effect of age for females: %f", dahe_ci95L)
sprintf("95 CI upper bound for partial effect of age for females: %f", dahe_ci95H)


#**********************************************************************************************
# 4. COMBINING LOGARITHMIC AND INTERACTIONS REGRESSIONS

# A. CREATE INTERACTIONS

## Create the interaction between female and log(age)
mydata1$female_log_age=mydata1$female*mydata1$log_age


# B. RUN INTERACTIVE LOGARITHMIC REGRESSIONS

## Regression of log(ahe) on age, allowing for differential gender effects with bachelor, + controls
reg7=lm(log_ahe~age+female_age+female+bachelor+d1992,data=mydata1)
cov7=vcovHC(reg7, type = "HC1")    
se7=sqrt(diag(cov7))

## Regression of log(ahe) on log(age), allowing for differential gender effects with bachelor, + controls
reg8=lm(log_ahe~log_age+female_log_age+female+bachelor+d1992,data=mydata1)
cov8=vcovHC(reg8, type = "HC1")    
se8=sqrt(diag(cov8))

## Regression output table
# Discuss the results from stargazer() as asked in the question on the assignment sheet.
stargazer(reg7, reg8, type="text",
          se=list(se7, se8),
          digits=3, 
          dep.var.labels=c("Log(AHE)"),
          covariate.labels=
            c("Age",
              "Age x Female",
              "Log(Age)",
              "Log(Age) x Female",
              "Female",
              "Bacelor Degree",
              "1992 Dummy",
              "Constant"),          
          out="reg_output3.txt")   # Output results to your director in a text file



# C. COMPUTE PARTIAL EFFECTS AND THEIR CONFIDENCE INTERVALS

## Elasticity of ahe with respect to ahe for females is the sum of the 
# log_age and female_log_age coefficients in reg8
coef_log_age=summary(reg8)$coefficients[2, 1]
coef_female_log_age=summary(reg8)$coefficients[3, 1]
ahe_elasticity_female=coef_log_age+coef_female_log_age

## Fstatistic for Test that Sum of Coefficients Equals 0: log_age+female_log_age=0
# Note: this continues to exactly follow the general approach for computing standard errors for partial effects in nonlinear
# regression models on slides 19 to 23 of lecture note 8, where the change here is whether the female dummy equals 1
Ftest=linearHypothesis(reg8,c("log_age+female_log_age=0"),vcov = vcovHC(reg8, "HC1"))

## Recover the Fstat from the joint test results in Ftest
Fstat=Ftest[2,3]
sprintf("Fstat %f", Fstat)

## Compute the standard error for the partial effect we computed, dahe (see slide 21 of Lecture note 8) 
se_ahe_elasticity_female=abs(ahe_elasticity_female)/sqrt(Fstat)

## 95% CI for the partial effect we computed, dahe
ahe_elasticity_female_ci95L=ahe_elasticity_female-se_ahe_elasticity_female*1.96
ahe_elasticity_female_ci95H=ahe_elasticity_female+se_ahe_elasticity_female*1.96

## Outputting results
sprintf("ahe-age elasticity for females: %f", ahe_elasticity_female)
sprintf("SE of ahe-age elasticity for females: %f", se_ahe_elasticity_female)
sprintf("95 CI lower bound ahe-age elasticity for females: %f", ahe_elasticity_female_ci95L)
sprintf("95 CI upper bound ahe-age elasticity for females: %f", ahe_elasticity_female_ci95H)


