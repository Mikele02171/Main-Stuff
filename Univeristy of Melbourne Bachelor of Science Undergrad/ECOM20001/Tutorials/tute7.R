#**********************************************************************************************
# Tutorial 7 Code
# By: David Byrne
# Objectives: Dummy variables, heteroskedasticity, omitted variables
#**********************************************************************************************

#**********************************************************************************************
# 0. INSTALLING PACKAGES

# In this tutorial, we will use 3 new commands: coeftest(), vcovHC(), and stargazer()
  # coeftest() and vcovHC() compute and display heteroskedasticity-robust (or "White")  standard errors
  # stargazer() is used to report different multiple regression results for the same dependent variable
  # but for models with different independent variables in an easy-to-read table

# To use these commands you need to install additional R packages, which you can do through RStudio
  # For vcovHC(), you need to install the "AER" package, which stands for "Applied Econometrics with R"
  # For stargazer(), you need to install the "stargazer" package 

# INSTALLATION of AER AND STARGAZER packages
  # To install stargazer type the following in your RStudio console: install.packages("stargazer")
  # To install AER type the following in your RStudio console: install.packages("AER")


#**********************************************************************************************
# 1. SET WORKING DIRECTORY AND PACKAGES

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial7")

## Load Applied Econometrics package (see above for installing AER package)
library(AER)

## Load Stargazer package for regression tables (see above for installing stargazer package)
library(stargazer)


#**********************************************************************************************
# 2. LOAD DATA

## Load dataset on income and height
mydata1=read.csv(file="tute7_smoke.csv")

## List the variables in the dataset named mydata1
names(mydata1)

## Dimension of the dataset
# 3000 observations (babies and their mothers)
# 13 variables: id, birthweight, smoker, alcohol, drinks, nprevisit, tripre1, tripre2, tripre3,
#               tripre0, unmarried, educ, age            
dim(mydata1)


#**********************************************************************************************
# 3. SUMMARY STATISTICS AND OMITTED VARIABLES

# A. SUMMARY STATISTICS

# Compute summary statistics to get a sense of a typical (baby,mother) pair in the data
summary(mydata1)
sd(mydata1$birthweight)
sd(mydata1$smoker)
sd(mydata1$alcohol)
sd(mydata1$nprevisit)
sd(mydata1$unmarried)
sd(mydata1$educ)
sd(mydata1$age)


# B. GRAPHICAL EVIDENCE OF BIRTH WEIGHT AND MOTHERS SMOKING

# Birthweight probability densities among smokers and non-smokers
pdf("dens_birthweight_smoking.pdf")
plot(density(mydata1$birthweight[mydata1$smoker==1]), 
    col="red",lty=1,main="Birthweight Among Smoking and Non-Smoking Mothers", xlab="Birthweight")
    lines(density(mydata1$birthweight[mydata1$smoker==0]), col="blue",lty=2)
    legend("topright", legend=c("Smoker", "Non-Smoker"), 
    col=c("red","blue"), lty=c(1,2))
dev.off()

# T-test of difference in birthweight for smokers and non-smokers
mean(mydata1$birthweight[mydata1$smoker==1])
mean(mydata1$birthweight[mydata1$smoker==0])
mean(mydata1$birthweight[mydata1$smoker==1])-mean(mydata1$birthweight[mydata1$smoker==0])
t.test(mydata1$birthweight[mydata1$smoker==1],mydata1$birthweight[mydata1$smoker==0])


# C. EVALUATING THE POTENTIAL FOR OMITTED VARIABLE BIAS AND IMPORTANCE OF CONTROLS

# 1. Birth weight, smoking, alcohol

# Birth weight densities, drinkers and non-drinkers
pdf("dens_birthweight_drinking.pdf")
plot(density(mydata1$birthweight[mydata1$alcohol==1]), 
    col="red",lty=1,main="Birthweight Among Drinking and Non-Drinking Mothers", xlab="Birthweight")
    lines(density(mydata1$birthweight[mydata1$alcohol==0]), col="blue",lty=2)
    legend("topright", legend=c("Drinker", "Non-Drinker"), 
    col=c("red","blue"), lty=c(1,2))
dev.off()

# T-test of difference in drinking for smokers and non-smokers
mean(mydata1$alcohol[mydata1$smoker==1])
mean(mydata1$alcohol[mydata1$smoker==0])
mean(mydata1$alcohol[mydata1$smoker==1])-mean(mydata1$alcohol[mydata1$smoker==0])
t.test(mydata1$alcohol[mydata1$smoker==1],mydata1$alcohol[mydata1$smoker==0])


# 2. Birth weight, smoking, prenatal care

# Birth weight densities, with and without pre-natal care
pdf("dens_birthweight_prenatal.pdf")
plot(density(mydata1$birthweight[mydata1$tripre0==0]), 
    col="red",lty=1,main="Birthweight Among Babies With and Without Prenatal Care", xlab="Birthweight")
    lines(density(mydata1$birthweight[mydata1$tripre0==1]), col="blue",lty=2)
    legend("topright", legend=c("Pre-Natal Care", "No Pre-Natal Care"), 
    col=c("red","blue"), lty=c(1,2))
dev.off()

# T-test of difference in prenatal care for smokers and non-smokers
mean(mydata1$tripre0[mydata1$smoker==1])
mean(mydata1$tripre0[mydata1$smoker==0])
mean(mydata1$tripre0[mydata1$smoker==1])-mean(mydata1$tripre0[mydata1$smoker==0])
t.test(mydata1$tripre0[mydata1$smoker==1],mydata1$tripre0[mydata1$smoker==0])


# 3. Birth weight, smoking, education

# Scatterplot between birth weight and education with line of best fit
birthweight_educ_reg=lm(birthweight~educ,data=mydata1)
pdf("scat_birthweight_educ.pdf")
plot(mydata1$educ,mydata1$birthweight,
     main="Birth Weight and Years of Education",
     xlab="Years of Education",
     ylab="Birth Weight",
     col="grey",
     pch=16)
abline(birthweight_educ_reg, col="red", lwd=2)
dev.off()

# T-test of difference in education for smokers and non-smokers
mean(mydata1$educ[mydata1$smoker==1])
mean(mydata1$educ[mydata1$smoker==0])
mean(mydata1$educ[mydata1$smoker==1])-mean(mydata1$educ[mydata1$smoker==0])
t.test(mydata1$educ[mydata1$smoker==1],mydata1$educ[mydata1$smoker==0])


#**********************************************************************************************
# 4. REGRESSIONS: coeftest()

# A. CHECKING HOMOSKEDASTICITY AND HETEROSKEDASTICITY

# Comparing single linear regression results of birth weight on smoking status, accounting
# and not accounting for heteroskedasticity

# The coeftest() command is used to compute heteroskedasticity-robust standard errors
# To run the command you take two steps, similar to how you output regression results
  # reg=lm(y~x,data=mydata)                     # run the regression
  # coeftest(reg, vcov = vcovHC(reg, "HC1"))    # print regression results with robust standard errors

# Notice that so far we have used summary(reg) to print out the regression results. 
# Reunning regressions with the following two steps products results assuming homoskedasticity
  # reg=lm(y~x,data=mydata)   # run the regression
  # summary(reg)              # print regression results with homoskedasticity

# Single linear regression results relating birthweight and smoking, assuming homoskedasticity
reg1=lm(birthweight~smoker,data=mydata1)
summary(reg1)

# Single linear regression results relating birthweight and smoking, allowing for heteroskedasticity
coeftest(reg1, vcov = vcovHC(reg1, "HC1")) 
summary(reg1)$adj.r.squared   # report the adjusted R-Squared from the regression

# Notice how the regression coefficients from summary(reg1) and coeftest(reg1, vcov = vcovHC(reg1, "HC1")) 
# are exactly the same, but the standard errors and t-statistics are different


# B. BUILDING UP THE REGRESSION MODEL 
# Building up the regression model by progressively adding control variables to evaluate 
# their impact on the coefficient of interest (smoker) and model fit 

# As we build up the model, we will use new R command called stargazer() to allow us 
# to output results from our regressions in an easily readable way. For each regression
# we use the lm() command to get the regression coefficient estimates, and the 
# vcovHC() + sqrt() commands to get the heteroskedasticity robust standard errors

# Single linear regression with no other controls
reg1=lm(birthweight~smoker,data=mydata1)  # save regression results for reg1
cov1=vcovHC(reg1, type = "HC1")           # next 2 lines save the robust standard errors for reg1
se1=sqrt(diag(cov1))

# Controlling for alcohol
reg2=lm(birthweight~smoker+alcohol+drinks,data=mydata1) # save regression results for reg2
cov2=vcovHC(reg2, type = "HC1")                         # next 2 lines save the robust standard errors for reg2
se2=sqrt(diag(cov2))                    

# Controlling for alcohol, prenatal care
reg3=lm(birthweight~smoker+alcohol+drinks+nprevisit+tripre1+tripre2+tripre3,data=mydata1) # save regression results for reg3
cov3=vcovHC(reg3, type = "HC1")                         # next 2 lines save the robust standard errors for reg3
se3=sqrt(diag(cov3))  

# Controlling for alcohol, prenatal care, demographics
reg4=lm(birthweight~smoker+alcohol+drinks+nprevisit+tripre1+tripre2+tripre3+age+educ+unmarried,data=mydata1) # save regression results for reg4
cov4=vcovHC(reg4, type = "HC1")                         # next 2 lines save the robust standard errors for reg4
se4=sqrt(diag(cov4))  

# Controlling for alcohol, prenatal care, demographics
# Assuming homoskedastic standard errors for comparison to reg4
reg5=lm(birthweight~smoker+alcohol+drinks+nprevisit+tripre1+tripre2+tripre3+age+educ+unmarried,data=mydata1) # save regression results for reg5
cov5=vcovHC(reg5, type = "const")                         # next 2 lines save the standard errors for reg5
se5=sqrt(diag(cov5))  

## Regression output table for the 4 regressions reg1 reg2 reg3 reg4
  # Reporting with 2 digits after decimal with 'digits=2' command
  # First line lists the regression coefficient estimates we saved
  # Second line se() lists the standard errors we saved
  # Third line digits=2 says to report 2 digits after the decimal
  # Fourth line dep.var.labels=c() creates the label for the dependent variable
  # Fifth line covariate.labels= (and the lines after) create the labels for the independent variables
  # The last line with out= creates the .txt file with the regression output
stargazer(reg1, reg2, reg3, reg4, reg5, type="text",
          se=list(se1, se2, se3, se4, se5),
          digits=2, 
          dep.var.labels=c("Baby Birthweight in Grams"),
          covariate.labels=
            c("Smoker",
              "Drinks Alcohol During Pregnancy",
              "Drinks per Week During Pregnancy",
              "Prenatal Visits",
              "Prenatal Care in 1st Trimester",
              "Prenatal Care in 2nd Trimester",
              "Prenatal Care in 3rd Trimester",
              "Age",
              "Years of Education",
              "Unmarried",
              "Constant"),
          out="reg_output.txt")   # Output results to your director in a text file

# What does Note *p<0.1; **p<0.05; ***p<0.01 in the table mean?
  # This is a legend for hypothesis test results reported in the table for individual regression
  # coefficients. Specifically, a regression coefficient in the table with either a "*", "**" or "***"
  # is statistically significantly different from 0 at the 10%, 5%, and 1% level depending on 
  # how many stars are next to the coefficient (hence the name of the command 'stargazer()')
  # More precisely, these stars "*" indicate results from a hypothesis test that a given regression 
  # coefficient equals 0 against the alternative that the coefficient does not equal 0 
  # (e.g., the stars correspond to results from a 2-tailed test of the null a coefficient equals 0)



