#**********************************************************************************************
# Tutorial 8 Code
# By: David Byrne
# Objectives: Multiple linear regression, dummy variable trap
#**********************************************************************************************


#**********************************************************************************************
# 1. SET WORKING DIRECTORY AND LOADING PACKAGES

## Set the working directory for the tutorial file
setwd("/Users/byrned/Dropbox/Teaching/20001/Tutorials/Tutorial8")

## Load AER package for coeftest() and vcovHC() commands for
## for computing heteroskedasticity robust standard errors
library(AER)

## Load stargarzer package for making nice regression tables
library(stargazer)

# Note that if you have not already done so (say in Tutorial 7), you must 
# install the AER and stargazer package by separately typing 
# install.packages("AER") and install.packages("stargazer") in the RStudio Console 
# See Tutorial 7, and specifically the tute7.pdf or tute7.R files for details on 
# installing and loading packages. 

# If you previously installed these packagesin Tutorial 7, then you do not have to 
# install them again; they should load using the library() command without issue.


#**********************************************************************************************
# 2. LOAD DATA

## Load dataset on income and height
mydata1=read.csv(file="tute8_smoke.csv")

## List the variables in the dataset named mydata1
names(mydata1)

## Dimension of the dataset
# 3000 observations (babies and their mothers)
# 13 variables: id, birthweight, smoker, alcohol, drinks, nprevisit, tripre1, tripre2, tripre3,
#               tripre0, unmarried, educ, age            
dim(mydata1)


#**********************************************************************************************
# 3. CONSTANT REGRESSOR AND THE DUMMY VARIABLE TRAP

# NOTE: before continuing with the rest of the tutorial, make sure you have the AER package ticked
# on under the "Packages Tab" to the right of your R-Studio screen

# A. CONSTANT REGRESSOR

# First to note that the regressors tripre0, tripre1, tripre2, tripre3 put each observation
# into one and only one of G=4 groups. Either a baby had:
# first had prenatal care in the 1st trimester (tripre1==1)
# first had prenatal care in the 2nd trimester (tripre2==1)
# first had prenatal care in the 3rd trimester (tripre3==1)
# never had prenatal care in any trimesters (tripre0==1)

# That is, for a given observation, one and only one of tripre0, tripre1, tripre2, tripre3 equals 1,
# and the 3 other regressors will equal 0
# Can check this by constructing a new regressor constant=tripre0+tripre1+tripre2+tripre3
# and showing that constant==1 for EVERY observation in the sample

## Create a new regressor that is the sum of tripre0, tripre1, tripre2, triepre2
## This is also known as the "Constant Regressor" denoted X0 from Lecture Note 6
mydata1$constant=mydata1$tripre0+mydata1$tripre1+mydata1$tripre2+mydata1$tripre3

## Summarize the constant variable - it's always 1!
summary(mydata1$constant)

## Simple linear regression of birthweight on alcohol
reg1=lm(birthweight~alcohol,data=mydata1)
coeftest(reg1, vcov = vcovHC(reg1, "HC1")) 

# We can estimate regressions in R WITHOUT the constant by adding a "+0"
# at the end of the list of regressors in the lm() function
# General regression code with regressor:   reg=lm(yvar~xvar1+xvar2+..+xvark)
# General regression code without constant: reg=lm(yvar~xvar1+xvar2+..+xvark+0)

## Simple linear regression of birthweight on alcohol without constant
reg2=lm(birthweight~alcohol+0,data=mydata1)
coeftest(reg2, vcov = vcovHC(reg2, "HC1")) 

## Simple linear regression of birthweight on alcohol without constant, and with
## "constant=tripre0+tripre1+tripre2+tripre3" variable that we created
reg3=lm(birthweight~constant+alcohol+0,data=mydata1)
coeftest(reg3, vcov = vcovHC(reg3, "HC1")) 

# Notice how reg1 and reg3 produce identical results, thereby highlighting the role of
# the constant regressor in multiple linear regression


# B. FALLING INTO THE DUMMY VARIABLE TRAP

# Try running the regression including our "constant" variable but not dropping
# the constant from the regression (e.g., do not have the "+0" part). This represents 
# a dummy variable trap because our "constant" variable is perfectly collinear 
# with the constant regressor on the model's intercept

## Trying to fall into dummy variable trap
reg4=lm(birthweight~constant+alcohol,data=mydata1)
coeftest(reg4, vcov = vcovHC(reg4, "HC1"))

## Re-run simple original regression without the constant variable
reg1=lm(birthweight~alcohol,data=mydata1)
coeftest(reg1, vcov = vcovHC(reg1, "HC1"))

# What happens? reg4 and reg1 yields the EXACT SAME results
# Why? Because R automatically drops the "constant" variable in reg4 to
# avoid the dummy variable trap. Notice how the program does not tell you that it does this
# So when running regressions with lots of dummy variables in R, it is important 
# to check with your inputted variable list and the regression output in coeftest() 
# that the inputted and outputted variable list is the same. If it is not, then R
# may have automatically dropped some of your dummy variables to avoid the dummy variable trap

# Let's try to fall into the dummy variable trap again to cement ideas. This time we will
# include tripre0, tripre1, tripre2, tripre3 as regressors in our regression. Collectively
# these regressors are perfectly collinear with the constant regressor

## Regression trying to fall into the dummy variable trap again
reg6=lm(birthweight~alcohol+tripre0+tripre1+tripre2+tripre3,data=mydata1)
coeftest(reg6, vcov = vcovHC(reg6, "HC1"))

# Notice what happens: R automatically drops tripre3 to avoid the dummy variable trap, the last
# variable in the regression.

# This is important because it means that tripre3 becomes our omitted category (or "base group")
# meaning that the interpretation of tripre0, tripre1, tripre2 equaling one on birthweight is 
# RELATIVE to observations where tripre3==1. This is important for interpretation of our results:

# tripre0=-569.321 means RELATIVE to tripre3==1, babies with no prenatal care weigh 569 grams LESS
# than babies that had their first prenatal care in the 3rd trimester, and this difference is 
# statistically significant at the 1% level

# tripre1=180.603 means RELATIVE to tripre3==1, babies with their first prenatal care in the 1st 
# trimester weigh 180 grams MORE than babies that had their first prenatal care in the 3rd trimester,
# and this difference is statistically significant at the 1% level

# tripre2=55.707 means RELATIVE to tripre3==1, babies with their first prenatal care in the 2nd 
# trimester weigh 180 grams MORE than babies that had their first prenatal care in the 3rd trimester,
# and this difference is NOT statistically significant at the 1% level

# For interpretation, it might be easier to make our base group babies for whom tripre0==1, 
# that is, those who do not have any prenatal care. Here, as model builders, we explicitly omit
# tripre0 from the list of regressors to avoid the dummy variable trap and make it our base group 
# as opposed to having R simply choose the base group for us

## Regression where we explicitly make tripre0==1 the base group
reg7=lm(birthweight~alcohol+tripre1+tripre2+tripre3,data=mydata1)
coeftest(reg7, vcov = vcovHC(reg7, "HC1"))

# Notice how the regression coefficient on alcohol is identical in reg6 and reg7; this is because
# we are still holding all other factors fixed in equivalent ways in estimating the alcohol
# regression coefficient, irrespective of what the chose base group among the tripre0, tripre1,
# tripre2, and tripre3 is.

# Also notice how the intercept and coefficients on tripre1 and tripre2 are different in reg6 and reg7,
# in particular they are much larger. Why? Because our base group is now the babies where tripre0==1
# meaning the interpretation of the tripre1, tripre2, and tripre3 coefficients are all relative to 
# babies without prenatal visits. 

# Explicitly provide the interpretations on the tripre1, tripre2, tripre3 coefficients
# in answering the tutorial questions similar to the interpretations provided above.


#**********************************************************************************************
# 4. MULTICOLLINEARITY

# Imperfect multicollinearity is not a logical problem with the regression like perfect
# collinearity, but it can yield much larger standard errors in your regression coefficients

# First notice there is a strong relationship between gambles and tripre0, but they are not 
# perfectly colinear, but most mothers who gamble do not have prenatal care
# xtabs(~x,y) function is useful for assessing high collinearity between gambles and tripre0
# It produces a cross-tabulation of all the combinations of values of gambles and tripre0
# Because gambles and tripre0 are dummy variables, there are four possible combinations
# (tripre0,gambles) is either (0,0), (0,1), (1,0), or (1,1)

## Cross-tabulation of tripre0 and gambles
xtabs(~tripre0+gambles,data=mydata1)

# The results from xtabs tells us there are in total 26 (1,1) instances of mothers 
# with tripre0=1 and gambles=1. There are 4 instances where tripre0=1 and gambles=0
# That is, if a mother does not have prenatal care in the data, she is likely to gamble
# Because tripre0 is directly related to tripre1, tripre2, and tripre3 as discussed above,
# this means that there is a potential issue of high collinearity between the gambles variable
# and tripre1, tripre2, and tripre3 

# Lets look at the impact of this high colinearity by running regressions that vary which regressors
# are in the regression as asked in the tutorial questions file
# I am re-starting the regression counter number here at reg1. 

## Regressions, storing and outputting the regression results using stargazer()
# See tute7.pdf and tute7.R for a detailed introduction to stargazer() 
reg1=lm(birthweight~smoker+alcohol+drinks+gambles+unmarried+educ+age,data=mydata1)  # Regression estimates for reg1
cov1=vcovHC(reg1, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se1=sqrt(diag(cov1))

reg2=lm(birthweight~smoker+alcohol+drinks+gambles+nprevisit+unmarried+educ+age,data=mydata1)
cov2=vcovHC(reg2, type = "HC1")    
se2=sqrt(diag(cov2))

reg3=lm(birthweight~smoker+alcohol+drinks+nprevisit+tripre1+tripre2+tripre3+unmarried+educ+age,data=mydata1)
cov3=vcovHC(reg3, type = "HC1")    
se3=sqrt(diag(cov3))

reg4=lm(birthweight~smoker+alcohol+drinks+gambles+nprevisit+tripre1+tripre2+tripre3+unmarried+educ+age,data=mydata1)
cov4=vcovHC(reg4, type = "HC1")    
se4=sqrt(diag(cov4))

## Regression output table for the 4 regressions reg1 reg2 reg3 reg4
# Discuss the results from stargazer() as asked in the question on the assignment sheet.

stargazer(reg1, reg2, reg3, reg4, type="text",
          se=list(se1, se2, se3, se4),
          digits=2, 
          dep.var.labels=c("Baby Birthweight in Grams"),
          covariate.labels=
            c("Smoker",
              "Drinks Alcohol During Pregnancy",
              "Drinks per Week During Pregnancy",
              "Gambles",
              "Prenatal Visits",
              "Prenatal Care in 1st Trimester",
              "Prenatal Care in 2nd Trimester",
              "Prenatal Care in 3rd Trimester",
              "Unmarried",
              "Years of Education",
              "Age",
              "Constant"),
          out="reg_output.txt")   # Output results to your director in a text file

## Computing Regression F-Statistics Accounting for Heteroskedasticity
## NOTE: 'stargazer' reports homoskedastic regression F-statistics
# To compute the correct F-statistic for each regression, we can use the linearHypothesis() 
# compand which allows us to compute joint hypothesis tests, which includes the
# regression F-statistics (which tests the null that all the coefficients are jointly 0).

# reg1 Regression F-statistic, accounting for heteroskedasticity
linearHypothesis(reg1,c("smoker=0",
                        "alcohol=0",
                        "drinks=0",
                        "gambles=0",
                        "unmarried=0",
                        "educ=0",
                        "age=0"),vcov = vcovHC(reg1, "HC1"))

# reg2 Regression F-statistic, accounting for heteroskedasticity
linearHypothesis(reg2,c("smoker=0",
                        "alcohol=0",
                        "drinks=0",
                        "gambles=0",
                        "nprevisit=0",
                        "unmarried=0",
                        "educ=0",
                        "age=0"),vcov = vcovHC(reg2, "HC1"))

# reg3 Regression F-statistic, accounting for heteroskedasticity
linearHypothesis(reg3,c("smoker=0",
                        "alcohol=0",
                        "drinks=0",
                        "nprevisit=0",
                        "tripre1=0",
                        "tripre2=0",
                        "tripre3=0",
                        "unmarried=0",
                        "educ=0",
                        "age=0"),vcov = vcovHC(reg3, "HC1"))

# reg4 Regression F-statistic, accounting for heteroskedasticity
linearHypothesis(reg4,c("smoker=0",
                      "alcohol=0",
                      "drinks=0",
                      "gambles=0",
                      "nprevisit=0",
                      "tripre1=0",
                      "tripre2=0",
                      "tripre3=0",
                      "unmarried=0",
                      "educ=0",
                      "age=0"),vcov = vcovHC(reg4, "HC1"))


