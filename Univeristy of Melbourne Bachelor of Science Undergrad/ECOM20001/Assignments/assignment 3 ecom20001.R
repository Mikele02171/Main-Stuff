##Assignment 3 ECOM20001
#Michael Le (998211) 


## Load Applied Econometrics Package for heteroskedasticity robust standard errors
library(AER)
## Load stargarzer package for making nice regression tables
library(stargazer)
## Load ggplot2 Package for Nice Graphs and Easily Fitting Curves
library(ggplot2)



##Question 1 
mydata2 = read.csv(file="as3_crime.csv")
mydata3 = read.csv(file="Assign3Q10mydata.csv")
dim(mydata2)
names(mydata2)


## In cubic form 
ggplot(mydata2, aes(y=robbery_rate, x=black)) +                                    # Define the dataset, x and y variables for scatter plot
  geom_point(alpha = .6) +                                              # Allow for shading of the points in the scatter plot to help visualisation
  stat_smooth(method = "lm", formula = y ~ poly(x,3), col="blue") +     # Fit a polynomial of DEGREE 3 (CUBIC)
  ggtitle("Relationship Between Robbery Rate and African American (Cubic)") +                    # Scatter plot title
  theme(plot.title = element_text(hjust = 0.5))                      # Center the scatter plot title

## In quadtic form 
ggplot(mydata2, aes(y=robbery_rate, x=black)) +                                    # Define the dataset, x and y variables for scatter plot
  geom_point(alpha = .6) +                                              # Allow for shading of the points in the scatter plot to help visualisation
  stat_smooth(method = "lm", formula = y ~ poly(x,4), col="red") +     # Fit a polynomial of DEGREE 4 (QUADTIC)
  ggtitle("Relationship Between Robbery Rate and African American (Quadtic)") +                    # Scatter plot title
  theme(plot.title = element_text(hjust = 0.5))                      # Center the scatter plot title

## Both scatterplots show a strong nonlinear relationship between the robbery rate and African Americans. As it reaches to 20% 
## of the population the number of robbery rates starts to slow down in the cubic scatterplot. 
## Where in the quadtic case slows down rapidly between 27-29% due to increase police arrests and public awareness and safety. 

##Question 2

## Create nonlinear terms for polynomial regressions (in case)
mydata2$black_2=mydata2$black*mydata2$black #squared
mydata2$black_3=mydata2$black*mydata2$black*mydata2$black #cubic 
mydata2$black_4=mydata2$black*mydata2$black*mydata2$black*mydata2$black #quadtic
mydata2$income_scale = mydata2$income / 1000 
## in $1000's

## From the assignment 2 we created the dummy variables 
# We denote these dummy variables first in vector form 
mydata2$d2000 = as.numeric(mydata2$year == 2000)
mydata2$d2001 = as.numeric(mydata2$year == 2001)
mydata2$d2002 = as.numeric(mydata2$year == 2002)
mydata2$d2003 = as.numeric(mydata2$year == 2003)
mydata2$d2004 = as.numeric(mydata2$year == 2004)
mydata2$d2005 = as.numeric(mydata2$year == 2005)
mydata2$d2006 = as.numeric(mydata2$year == 2006)
mydata2$d2007 = as.numeric(mydata2$year == 2007)
mydata2$d2008 = as.numeric(mydata2$year == 2008)
mydata2$d2009 = as.numeric(mydata2$year == 2009)
mydata2$d2010 = as.numeric(mydata2$year == 2010)


# Regression 1 
reg1=lm(robbery_rate~black+mydata2$black_2+mydata2$black_3+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)  # Regression estimates for reg1
cov1=vcovHC(reg1, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se1=sqrt(diag(cov1))

# Regression 2 
reg2=lm(robbery_rate~black+mydata2$black_2+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)  # Regression estimates for reg1
cov2=vcovHC(reg2, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se2=sqrt(diag(cov2))

# Regression 3
reg3=lm(robbery_rate~black+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)  # Regression estimates for reg1
cov3=vcovHC(reg3, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se3=sqrt(diag(cov3))


#Using the stargazer()
stargazer(reg1, reg2, reg3, type="text",
          se=list(se1, se2, se3),
          digits=2, 
          dep.var.labels=c("Number of robberies in the state per 100,000 people"),
          covariate.labels=
            c("Black Linear",
              "Black Squared",
              "Black Cubic",
              "income in $1000s",
              "Age",
              "Female",
              "dummy 2001",
              "dummy 2002",
              "dummy 2003",
              "dummy 2004",
              "dummy 2005",
              "dummy 2006",
              "dummy 2007",
              "dummy 2008",
              "dummy 2009",
              "dummy 2010",
              "Constant"),
          out="reg_output.txt") 


           

## The p values are less than 0.01. Meaning it is less than the signfifant level
## 5% so we safe to reject to null of no non-linear relationship between the robbery rate and 
## African Americans across all three regression models.

##Question 3

#The changing the percentage of Africian American from 5% to 10% can be predicted using the 
#OLS estimates corresponding to Reg(1) remaining other regression coefficents to be constant:
dY1 = (1784.90 * 0.10 - 6539.92 * 0.10 ** 2 + 7292.21 * 0.10 ** 3) - (1784.90*0.05 - 6539.92 * 0.05 ** 2 + 7292.21 * 0.05 ** 3) 
# Gives me 46.57628

# 10% to 15%
dY2 = (1784.90 * 0.15 - 6539.92 * 0.15 ** 2 + 7292.21 * 0.15 ** 3) - (1784.90*0.10 - 6539.92 * 0.10 ** 2 + 7292.21 * 0.10 ** 3)
# Gives me 24.815 

reg1=lm(robbery_rate~black+black_2+black_3+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)


#The changing the percentage of Africian American from 5% to 10% can be predicted using the 
#OLS estimates corresponding to Reg(1) remaining other regression coefficents to be constant:
newdata1= data.frame(black=0.05,black_2=0.05*0.05,black_3=0.05*0.05*0.05,age=1,female=1,income_scale=1,d2001=1,d2002=1,d2003=1,d2004=1,d2005=1,d2006=1,d2007=1,d2008=1,d2009=1,d2010=1)
newdata2= data.frame(black=0.10,black_2=0.10*0.10,black_3=0.10*0.10*0.10,age=1,female=1,income_scale=1,d2001=1,d2002=1,d2003=1,d2004=1,d2005=1,d2006=1,d2007=1,d2008=1,d2009=1,d2010=1)
robberyrate1=predict(reg1, newdata = newdata1)
robberyrate2=predict(reg1, newdata = newdata2)
robberyrate=robberyrate2-robberyrate1
## Partial Effect is 46.57635

#The changing the percentage of Africian American from 5% to 10% can be predicted using the 
#OLS estimates corresponding to Reg(1) remaining other regression coefficents to be constant:
newdata3= data.frame(black=0.10,black_2=0.10*0.10,black_3=0.10*0.10*0.10,age=1,female=1,income_scale=1,d2001=1,d2002=1,d2003=1,d2004=1,d2005=1,d2006=1,d2007=1,d2008=1,d2009=1,d2010=1)
newdata4= data.frame(black=0.15,black_2=0.15*0.15,black_3=0.15*0.15*0.15,age=1,female=1,income_scale=1,d2001=1,d2002=1,d2003=1,d2004=1,d2005=1,d2006=1,d2007=1,d2008=1,d2009=1,d2010=1)
robberyrate3=predict(reg1, newdata = newdata3)
robberyrate4=predict(reg1, newdata = newdata4)
robberyrate2a=robberyrate4-robberyrate3
## Partial Effect is 24.81504

## 5% to 10%
Ftest1=linearHypothesis(reg1,c("0.05*black + 0.0075*mydata2$black_2 + 0.000875*mydata2$black_3 = 0"),vcov = vcovHC(reg1, "HC1"))
Fstatistic1 = Ftest1[2,3]

se_robrate1=abs(robberyrate)/sqrt(Fstatistic1)
## 95% CI for the partial effect we computed, dahe
robrate1_ci95L=robberyrate-se_robrate1*1.96
robrate1_ci95H=robberyrate+se_robrate1*1.96
robrate1_ciwidth=robrate1_ci95H-robrate1_ci95L

## Outputting results
sprintf("partial effect: %f", robberyrate)
sprintf("SE of partial effect: %f", se_robrate1)
sprintf("95 CI lower bound for partial effect: %f", robrate1_ci95L)
sprintf("95 CI upper bound for partial effect: %f", robrate1_ci95H)
sprintf("Width of 95 CI for partial effect: %f", robrate1_ciwidth)

#10% to 15%
Ftest2=linearHypothesis(reg1,c("0.05*black + 0.0125*mydata2$black_2 + 0.002375*mydata2$black_3 = 0"),vcov = vcovHC(reg1, "HC1"))
Fstatistic2 = Ftest1[2,3]

se_robrate2=abs(robberyrate2a)/sqrt(Fstatistic2)
## 95% CI for the partial effect we computed, dahe
robrate2_ci95L=robberyrate2a-se_robrate2*1.96
robrate2_ci95H=robberyrate2a+se_robrate2*1.96
robrate2_ciwidth=robrate2_ci95H-robrate2_ci95L


## Outputting results
sprintf("partial effect: %f", robberyrate2a)
sprintf("SE of partial effect: %f", se_robrate2)
sprintf("95 CI lower bound for partial effect: %f", robrate2_ci95L)
sprintf("95 CI upper bound for partial effect: %f", robrate2_ci95H)
sprintf("Width of 95 CI for partial effect: %f", robrate2_ciwidth)

## Both partial effects given are 46.57628 and 24.815. Since we are now accounting for the fact that 
## the percentage rate of African Amercian influences the partial effect on black
## on robbery rates in the states in our non linear model.



##Question 4
mydata2$log_robbery_rate = log(mydata2$robbery_rate)
mydata2$log_black = log(mydata2$black)

mydata2$start = mydata2$year<=2003
mydata2$middle=mydata2$year>=2004&mydata2$year<=2007
mydata2$end = mydata2$year>=2008

mydata2$log_black_income = mydata2$log_black * mydata2$income_scale
mydata2$log_black_start = mydata2$log_black * mydata2$start
mydata2$log_black_middle = mydata2$log_black * mydata2$middle
mydata2$log_black_end = mydata2$log_black * mydata2$end

#Reg 1 
reg4=lm(log_robbery_rate~black+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)  # Regression estimates for reg1
cov4=vcovHC(reg4, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se4=sqrt(diag(cov4))

#Reg 2
reg5=lm(log_robbery_rate~log_black+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)  # Regression estimates for reg1
cov5=vcovHC(reg5, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se5=sqrt(diag(cov5))

#Reg 3
reg6=lm(log_robbery_rate~log_black+log_black_middle+log_black_end+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)  # Regression estimates for reg1
cov6=vcovHC(reg6, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se6=sqrt(diag(cov6))


#Reg4
reg7=lm(log_robbery_rate~log_black+log_black_income+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)  # Regression estimates for reg1
cov7=vcovHC(reg7, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se7=sqrt(diag(cov7))

#Using the stargazer()
stargazer(reg4, reg5, reg6, reg7, type="text",
          se=list(se4, se5, se6, se7),
          digits=2, 
          dep.var.labels=c("Logarithm robbery rate"),
          covariate.labels=
            c("Black",
              "Log Black",
              "Log Black Middle",
              "Log Black End",
              "Log Black income",
              "income in $1000s",
              "Age",
              "Female",
              "dummy 2001",
              "dummy 2002",
              "dummy 2003",
              "dummy 2004",
              "dummy 2005",
              "dummy 2006",
              "dummy 2007",
              "dummy 2008",
              "dummy 2009",
              "dummy 2010",
              "Constant"),
          out="reg_output.txt") 

##Question 5
#Recall standard derivations

#Standard derviation for black
sd(mydata2$black)

#0.09538564

#Standard derivation for logarithm black
sd(log_black)

#1.205834


# Given one standard deriation increase in the logarithm robbery rate are 0.09538564 * 4.07 = 0.3882195548 and 1.205834 * 0.59 = 0.71144206
## for the regression models 1 and 2 respectively holding the other regressors fixed. From the table
## both coefficent estimates are statistically significant different from 0 at 5% level of significance 
## as the p value is less than 0.01. 



##Question 6
#Recall standard derivations

#Standard derviation for black middle
sd(as.matrix(log_black_middle))
# 3305.83


#Standard derivation for black end
sd(as.matrix(log_black_end))
#3305.944

#Given one standard derivation increase in logarithm robbery rate for the logartihm for black between 2004 and 2007
#and the logarithm robbery rate for black from 2008 onwards are 33.0583 and 99.17832 holding other regressors fixed. 
#From the table both coefficents estimates are statistically significant different from 0 at 5% level of signifiance
#as the p value is less than 0.01


##Question 7

linearHypothesis(reg6,c("log_black_middle = log_black_end"),vcov = vcovHC(reg6, "HC1"))
# Here is the R output from the linearHypothesis() command for Regression 3 from Question 4 
# for the test H0: log_black_middle = log_black_end vs. H1: log_black_middle =! log_black_end.
# The F statistic is 3*10^-4 it has 533 and 1 degree of freedom, and p value is 0.986. 

##Question 8


reg7=lm(log_robbery_rate~log_black+log_black_income+income_scale+age+female+d2001+d2002+d2003+d2004+d2005+d2006+d2007+d2008+d2009+d2010,data=mydata2)
#Case 1: income is $30000 
#The predicted value from the running the regression in Regression 4 from Question 4 can be written as

#Y.hat = log(robbery_rate).hat = beta(0).hat + beta(1).hat * log_black + beta(2).hat*log_black_income 
# + beta(3).hat*income_scale+ beta(4).hat*age + beta(5).hat*female + beta(6).hat * d2001 + beta(7).hat*d2002
# + beta(8).hat*d2003 + beta(9).hat*d2004 + beta(10).hat*d2005 + beta(11).hat*d2006 + beta(12).hat*d2007 
# + beta(13).hat*d2008 + beta(14).hat*d2009 + beta(15).hat*d2010


#Using this log-log equation, when the income_scale is 30 (income_scale = $30000/$1000 = 30), the predicted 
#value becomes 

#Y.hat = log(robbery_rate).hat = beta(0).hat + beta(1).hat*log_black + 30*beta(2).hat*log_black 
# + beta(3).hat*(30)+ beta(4).hat*age + beta(5).hat*female + beta(6).hat * d2001 + beta(7).hat*d2002
# + beta(8).hat*d2003 + be ta(9).hat*d2004 + beta(10).hat*d2005 + beta(11).hat*d2006 + beta(12).hat*d2007 
# + beta(13).hat*d2008 + beta(14).hat*d2009 + beta(15).hat*d2010

#which implies that the elasticity of robbery rate with the respect to black with the
#income scale is the sum of the coefficents 
#on log(black). 
#Computing this partial effect/elasticity based on the estimated coefficents from column 4 (Regression 4) 
#is
log_robberyrate1 = 0.39 + 30*0.005 


# Again followint the approach to computing standard errors for nonlinear effects on slides 16-24 of lecture note 8
# we can obtain the F statistic from the joint test based on the elasticity for income_scaled that we just 
# derived in the linear Hypthesis input in R. 
Ftest3=linearHypothesis(reg7,c("log_black = 0"),vcov = vcovHC(reg7, "HC1"))
Fstatistic3 = Ftest3[2,3]
sprintf("Fstat %f", Fstatistic3)
#This test yields an F statistic of 16.213881. 

# The standard error for the partial error for the partial effect/elasticity for scaled income is then
# computed as 
se_logrobbery_rate1=abs(log_robberyrate1 )/sqrt(Fstatistic3)
## 95% CI for the partial effect we computed, robbery rate
log_robrate1_ci95L=log_robberyrate1-se_logrobbery_rate1*1.96
log_robrate1_ci95H=log_robberyrate1+se_logrobbery_rate1*1.96
log_robrate1_ciwidth=log_robrate1_ci95H-log_robrate1_ci95L

## Outputting results
sprintf("partial effect: %f", log_robberyrate1)
sprintf("SE of partial effect: %f", se_logrobbery_rate1)
sprintf("95 CI lower bound for partial effect: %f", log_robrate1_ci95L)
sprintf("95 CI upper bound for partial effect: %f", log_robrate1_ci95H)
sprintf("Width of 95 CI for partial effect: %f", log_robrate1_ciwidth)

# which implies that the 95% CI for the elasticity of robbery rate with the respect 
# of black for scaled income is [0.277151,0.802849]. 


#Case 2: income is $50000
#similiar to the previous case we follow
log_robberyrate2 = 0.39 + 50*0.005 

Ftest4=linearHypothesis(reg7,c("log_black= 0"),vcov = vcovHC(reg7, "HC1"))
Fstatistic4 = Ftest4[2,3]
sprintf("Fstat %f", Fstatistic4) # This test yields an F statistic of 16.213881. 

se_logrobbery_rate2=abs(log_robberyrate2 )/sqrt(Fstatistic4)
## 95% CI for the partial effect we computed, robbery rate
log_robrate2_ci95L=log_robberyrate2-se_logrobbery_rate2*1.96
log_robrate2_ci95H=log_robberyrate2+se_logrobbery_rate2*1.96
log_robrate2_ciwidth=log_robrate2_ci95H-log_robrate2_ci95L


## Outputting results
sprintf("partial effect: %f", log_robberyrate2)
sprintf("SE of partial effect: %f", se_logrobbery_rate2)
sprintf("95 CI lower bound for partial effect: %f", log_robrate2_ci95L)
sprintf("95 CI upper bound for partial effect: %f", log_robrate2_ci95H)
sprintf("Width of 95 CI for partial effect: %f", log_robrate2_ciwidth)


# which implies that the 95% CI for the elasticity of robbery rate with the respect 
# of black for scaled income is [0.328475,0.951525]. 

# We work with the percentage changes in Y and not just changes in Y in computing the 
# the standard error because of the interpretation of the log-log specification; the partial effects 
# are the terms of the percentage change in Y (robbery_rate) associated with a percentage change 
# in X (black) for both cases.

##Question 10 (Rough Idea)

# Evaluating the Impact of Relaxing Social Distancing Laws on the Spread of Covid-19
# Policy Question Answer: If Covid-19 
# will be suppressed, everything will follow 
# from the pre policices (before quanterine) 
# allowing more people to go to schools, travelling, reunions, work and businesses will resume back to normal.
# Hopefully China should change their policies and build a new system involving the population
# Salaries will be increased for employees and non employess working remotely, increased youth allowances
# and salaries to every ciziten who is currently living in Australia to able to 
# pay for food and supplies in public wearing a mask. Important to take care of yourself
# ensure to check the doctor if you have
# any sypthoms relating to the virus to aware others to prevent the spread. 

#Data 
# For the data section: I cover from the first to recent Covid-19 cases between 
# Late January 2020 to June 6th 2020 depending on the individual personal activities,
# professional work.


#Econmetric Model (From what I've answered from before can heavily effect the coefficents/variables I've created down below)
# Let Y be the total number of Covid-19 cases in Australia 
# X(1) = Number of people who had physical contact with someone who has the virus 
# X(2) = Number of people who had recovered from the virus 
# X(3) = Investigations 
# X(4) = Hospitalised
# X(5) = Number of Cases per month 
# X(6) = Overseas 
# X(7) = Infection in Hospitals 
# X(8) = Covid-19 Cases in Australia (locally)
# X(9) = Number of patients tested for Covid-19

#Ignore X1 
mydata3 = read.csv(file="Assign3Q10mydata.csv")

#Australian Covid-19 Cases vs. Overseas
ggplot(mydata3, aes(y=Total.Cases, x=Overseas)) +                                    # Define the dataset, x and y variables for scatter plot
  geom_point(alpha = .6) +                                              # Allow for shading of the points in the scatter plot to help visualisation
  stat_smooth(method = "lm", formula = y ~ poly(x,3), col="blue") +     # Fit a polynomial of DEGREE 3 
  ggtitle("Relationship Between Total Number of Covid-19 Cases in Australia and Overseas") +   # Scatter plot title
  theme(plot.title = element_text(hjust = 0.5))                      # Center the scatter plot title

#Australian Covid-19 Cases vs. Treatments
ggplot(mydata3, aes(y=Total.Cases, x=Tests)) +                                    # Define the dataset, x and y variables for scatter plot
  geom_point(alpha = .6) +                                              # Allow for shading of the points in the scatter plot to help visualisation
  stat_smooth(method = "lm", formula = y ~ poly(x,3), col="red") +     # Fit a polynomial of DEGREE 3
  ggtitle("Relationship Between Total Number of Covid-19 Cases in Australia and Treatments") +   # Scatter plot title
  theme(plot.title = element_text(hjust = 0.5))                      # Center the scatter plot title


#Australian Covid-19 Cases vs. Deaths
ggplot(mydata3, aes(y=Total.Cases, x=Deaths)) +                                    # Define the dataset, x and y variables for scatter plot
  geom_point(alpha = .6) +                                              # Allow for shading of the points in the scatter plot to help visualisation
  stat_smooth(method = "lm", formula = y ~ poly(x,3), col="black") +     # Fit a polynomial of DEGREE 3 
  ggtitle("Relationship Between Total Number of Covid-19 Cases in Australia and the number of deaths") +   # Scatter plot title
  theme(plot.title = element_text(hjust = 0.45))                      # Center the scatter plot title
                   
# Regression 1 
reg1=lm(mydata3$Total.Cases~mydata3$Deaths+mydata3$Recoveries, data = mydata3)  # Regression estimates for reg1
cov1=vcovHC(reg1, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se1=sqrt(diag(cov1))

# Regression 2 
reg2=lm(mydata3$Total.Cases~mydata3$Deaths+mydata3$Recoveries+mydata3$Overseas+mydata3$Contact,data=mydata3)  # Regression estimates for reg1
cov2=vcovHC(reg2, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se2=sqrt(diag(cov2))

# Regression 3
reg3=lm(mydata3$Total.Cases~mydata3$Deaths+mydata3$Recoveries+mydata3$Overseas+mydata3$Contact+mydata3$Hospitalised+mydata3$Month+ mydata3$Unknown.Contact+mydata3$Tests,data=mydata3)  # Regression estimates for reg1
cov3=vcovHC(reg3, type = "HC1")     # The next 2 lines produce heteroskedasticity-robust standard errors for reg1
se3=sqrt(diag(cov3))


#Using the stargazer()
stargazer(reg1, reg2, reg3, type="text",
          se=list(se1, se2, se3),
          digits=2, 
          dep.var.labels=c("Number of Covid-19 Cases in Australia"),
          covariate.labels=
            c("Deaths caused by covid-19",
              "Recoveries",
              "Overseas were effected by Covid-19",
              "Patient Contact with Covid-19",
              "Hospitalised",
              "Covid-19 Cases per month",
              "Unknown Contact",
              "Tests or Treatments",
              "Constant"),
          out="reg_output.txt") 

#Data observed from https://www.covid19data.com.au/

  





