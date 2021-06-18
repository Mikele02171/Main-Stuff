#**********************************************************************************************
# Assignment 3 Code
# By: David Byrne
# Objectives: Suggested Solutions
#**********************************************************************************************

#**********************************************************************************************
# SET WORKING DIRECTORY AND PREPARE DATA

## Clear data environment to start a fresh RStudio session
rm(list = ls(all.names = TRUE))

## Load Applied Econometrics package
library(AER)

## Load Stargazer package for regression tables
library(stargazer)

## Load ggplot for graphing
library(ggplot2)

## Set the working directory for the assignment
setwd("/Users/byrned/Dropbox/Teaching/20001/Assessment/Assignments/A3/")

## Load dataset
mydata=read.csv(file="as3_crime.csv")

## List the variables in the dataset named mydata
names(mydata)

## Dimension of the dataset
dim(mydata)


#**********************************************************************************************
# 1. NONLINEAR SCATTER PLOTS

## Scatter plot of log birthweight, nprevisit
pdf("q1a_scat.pdf")
ggplot(mydata, aes(y=mydata$robbery_rate, x=mydata$black)) +                        # Define the dataset, x and y variables for scatter plot
  geom_point(alpha = .3) +                                                          # Allow for shading of the points in the scatter plot to help visualisation
  stat_smooth(method = "lm", formula = y ~ poly(x,2), col="red") +                 # Fit a polynomial of DEGREE 2 (QUADRATIC)
  ggtitle("Quadratic Relationship Between Robbery Rate and Share of Black Population") +      # Scatter plot title
  theme(plot.title = element_text(hjust = 0.5)) +                                   # Center the scatter plot title
  scale_x_continuous(name="Share of Black Population") +                            # x-axis title, limits, lines
  scale_y_continuous(name="Robbery Rate per 100,000 People")                        # y-axis title, limits, lines
dev.off()

## Scatter plot of log birthweight, nprevisit
pdf("q1b_scat.pdf")
ggplot(mydata, aes(y=mydata$robbery_rate, x=mydata$black)) +                        # Define the dataset, x and y variables for scatter plot
  geom_point(alpha = .3) +                                                          # Allow for shading of the points in the scatter plot to help visualisation
  stat_smooth(method = "lm", formula = y ~ poly(x,3), col="blue") +                 # Fit a polynomial of DEGREE 2 (QUADRATIC)
  ggtitle("Cubic Relationship Between Robbery Rate and Share of Black Population") +      # Scatter plot title
  theme(plot.title = element_text(hjust = 0.5)) +                                   # Center the scatter plot title
  scale_x_continuous(name="Share of Black Population") +                            # x-axis title, limits, lines
  scale_y_continuous(name="Robbery Rate per 100,000 People")                        # y-axis title, limits, lines
dev.off()


#**********************************************************************************************
# 2. POLYNOMIAL REGRESSIONS

## Rescale income (ten thousand dollars) 
mydata$income_scale=mydata$income/10000

## Create year dummy variables
mydata$d2000=as.numeric(mydata$year==2000)
mydata$d2001=as.numeric(mydata$year==2001)
mydata$d2002=as.numeric(mydata$year==2002)
mydata$d2003=as.numeric(mydata$year==2003)
mydata$d2004=as.numeric(mydata$year==2004)
mydata$d2005=as.numeric(mydata$year==2005)
mydata$d2006=as.numeric(mydata$year==2006)
mydata$d2007=as.numeric(mydata$year==2007)
mydata$d2008=as.numeric(mydata$year==2008)
mydata$d2009=as.numeric(mydata$year==2009)
mydata$d2010=as.numeric(mydata$year==2010)

## Polynomials of robbery_rate
mydata$black_sq=mydata$black*mydata$black
mydata$black_cu=mydata$black*mydata$black*mydata$black

## Sequential hypothesis testing for polynomials
reg1=lm(robbery_rate~black+black_sq+black_cu+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010, data=mydata)
cov1=vcovHC(reg1, type = "HC1")
se1=sqrt(diag(cov1))

reg2=lm(robbery_rate~black+black_sq+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010, data=mydata)
cov2=vcovHC(reg2, type = "HC1")
se2=sqrt(diag(cov2))

reg3=lm(robbery_rate~black+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010, data=mydata)
cov3=vcovHC(reg3, type = "HC1")
se3=sqrt(diag(cov3))

## Polynomial regression output table
stargazer(reg1, reg2, reg3, type="text",
          se=list(se1, se2, se3),
          align=TRUE, dep.var.labels=c("Robbery Rate"),
          covariate.labels=
            c("Share of Pop. that is Black",
              "Share of Pop. that is Black Squared",
              "Share of Pop. that is Black Cubed",
              "Avg. Household Inc. (ten thousands)",
              "Avg. Age",
              "Share of Pop. that is Female",
              "2001",
              "2002",
              "2003",
              "2004",              
              "2005",
              "2006",
              "2007",
              "2008",
              "2009",
              "2010"),
          out="q2_reg_output.txt")

## Standard deviations for interpretations of statistically significant regression coefficients.
sd(mydata$black)


#**********************************************************************************************
# 3. NONLINEAR PARTIAL EFFECTS AND STANDARD ERRORS

## Black going from 0.05 to 0.10

## Predicted change in robberty_rate from changing black from 0.05 to 0.10
dY1=(1784.902*0.10-6539.925*0.10*0.10+7292.209*0.10*0.10*0.10)-(1784.902*0.05-6539.925*0.05*0.05+7292.209*0.05*0.05*0.05)

## F-statistic for changing black from 0.05 to 0.10
test1=linearHypothesis(reg1,c("0.05*black+0.0075*black_sq+0.000875*black_cu"),vcov = vcovHC(reg1, "HC1"))

## Print test results
linearHypothesis(reg1,c("0.05*black+0.0075*black_sq+0.000875*black_cu"),vcov = vcovHC(reg1, "HC1"))

## Standard error for predicted change in robberty_rate from changing nprevisit from 0.05 to 0.10
se1=abs(dY1)/sqrt(test1$F[2])

## 95% CI for predicted change in robberty_rate from changing nprevisit from 0.05 to 0.10
ci1_L=dY1-1.96*se1
ci1_H=dY1+1.96*se1

## Output from first test
paste("Predicted change in robbery_rate from changing black from 0.05 to 0.10:", dY1)
paste("Standard error of predicted change:", se1)
paste("95% CI lower bound of predicted change:", ci1_L)
paste("95% CI upper bound of predicted change:", ci1_H)

## Black share going from 0.10 to 0.15
## Predicted change in robberty_rate from changing black from 0.10 to 0.15
dY2=(1784.902*0.15-6539.925*0.15*0.15+7292.209*0.15*0.15*0.15)-(1784.902*0.10-6539.925*0.10*0.10+7292.209*0.10*0.10*0.10)

## F-statistic for changing black from 0.10 to 0.15
test2=linearHypothesis(reg1,c("0.05*black+0.0125*black_sq+0.002375*black_cu"),vcov = vcovHC(reg1, "HC1"))

## Print test results
linearHypothesis(reg1,c("0.05*black+0.0125*black_sq+0.002375*black_cu"),vcov = vcovHC(reg1, "HC1"))

## Standard error for predicted change in robberty_rate from changing nprevisit from 0.05 to 0.10
se2=abs(dY2)/sqrt(test2$F[2])

## 95% CI for predicted change in robberty_rate from changing nprevisit from 0.05 to 0.10
ci2_L=dY2-1.96*se2
ci2_H=dY2+1.96*se2

## Output from second test
paste("Predicted change in robbery_rate from changing black from 0.10 to 0.15:", dY2)
paste("Standard error of predicted change:", se2)
paste("95% CI lower bound of predicted change:", ci2_L)
paste("95% CI upper bound of predicted change:", ci2_H)


#**********************************************************************************************
# 4. LOGARITHMIC AND INTERACTIVE REGRESSIONS

# Create log robbery rate
mydata$log_robbery_rate=log(mydata$robbery_rate)

# Create log black
mydata$log_black=log(mydata$black)

# Dummies for start (2000-2003), middle (2004-2007), end of sample (2008-2010)
mydata$start=1*(mydata$year<=2003)
mydata$middle=1*(mydata$year>=2004 & mydata$year<=2007)
mydata$end=1*(mydata$year>=2008 & mydata$year<=2010)

# Interactions with start (2000-2003), middle (2004-2007), end of sample (2008-2010)
mydata$log_black_start=mydata$log_black*mydata$start
mydata$log_black_middle=mydata$log_black*mydata$middle
mydata$log_black_end=mydata$log_black*mydata$end

# Interaction of log_black with income
mydata$log_black_income=mydata$log_black*mydata$income_scale

# Regressions
reg1=lm(log_robbery_rate~black+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010, data=mydata)
cov1=vcovHC(reg1, type = "HC1")
se1=sqrt(diag(cov1))

reg2=lm(log_robbery_rate~log_black+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010, data=mydata)
cov2=vcovHC(reg2, type = "HC1")
se2=sqrt(diag(cov2))

reg3=lm(log_robbery_rate~log_black+log_black_middle+log_black_end+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010, data=mydata)
cov3=vcovHC(reg3, type = "HC1")
se3=sqrt(diag(cov3))

reg4=lm(log_robbery_rate~log_black+log_black_income+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010, data=mydata)
cov4=vcovHC(reg4, type = "HC1")
se4=sqrt(diag(cov4))


## Polynomial regression output table
stargazer(reg1, reg2, reg3, reg4, type="text",
          se=list(se1, se2, se3, se4),
          align=TRUE, dep.var.labels=c("Log(Robbery Rate)"),
          covariate.labels=
            c("Share of Pop. that is Black",
              "Log of Share of Pop. that is Black",
              "Log of Share of Pop. that is Black x Years 2004-2007",   
              "Log of Share of Pop. that is Black x Years 2008-2010",    
              "Log of Share of Pop. that is Black x Avg. Household Inc.",              
              "Avg. Household Inc. (ten thousands)",
              "Avg. Age",
              "Share of Pop. that is Female",
              "2001",
              "2002",
              "2003",
              "2004",              
              "2005",
              "2006",
              "2007",
              "2008",
              "2009",
              "2010"),
          out="q4_reg_output.txt")

#**********************************************************************************************
# 5. AND 6. INTERPRETATIONS

# See the as3sol.pdf document for discussion on interpretation of individual regression
# coefficients


#**********************************************************************************************
# 7. ELASTICITIES AT TIME PERIODS IN THE SAMPLE

## Test regression coefficients on smoker and alcohol are equal
linearHypothesis(reg3,c("log_black_middle=log_black_end"),vcov = vcovHC(reg3, "HC1"))


#**********************************************************************************************
# 8. ELASTICITIES AT DIFFERENT INCOME LEVELS

## Predicted elasticity, standard error, 95% CI at income_scale=3 (income=$30000)
dY1=0.385+0.046*3

# F-statistic for elasticity
test1=linearHypothesis(reg4,c("log_black+3*log_black_income=0"),vcov = vcovHC(reg4, "HC1"))

# Print test results
linearHypothesis(reg4,c("log_black+3*log_black_income=0"),vcov = vcovHC(reg4, "HC1"))

# Standard error for elasticity
se1=abs(dY1)/sqrt(test1$F[2])

# 95% CI for elasticity
ci1_L=dY1-1.96*se1
ci1_H=dY1+1.96*se1

# Output for elasticity at income=30,000
paste("Elasticity at income=$30,000", dY1)
paste("Standard error", se1)
paste("95% CI lower bound", ci1_L)
paste("95% CI upper bound", ci1_H)


## Predicted elasticity, standard error, 95% CI at income_scale=5 (income=$50000)
dY2=0.385+0.046*5

# F-statistic for elasticity
test2=linearHypothesis(reg4,c("log_black+5*log_black_income=0"),vcov = vcovHC(reg4, "HC1"))

# Print test results
linearHypothesis(reg4,c("log_black+5*log_black_income=0"),vcov = vcovHC(reg4, "HC1"))

# Standard error for elasticity
se2=abs(dY2)/sqrt(test2$F[2])

# 95% CI for elasticity
ci2_L=dY2-1.96*se2
ci2_H=dY2+1.96*se2

# Output for elasticity at income=50,000
paste("Elasticity at income=$50,000", dY2)
paste("Standard error", se2)
paste("95% CI lower bound", ci2_L)
paste("95% CI upper bound", ci2_H)






