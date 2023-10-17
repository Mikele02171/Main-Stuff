---
  title: "part3_code"
output: word_document
date: "2023-10-17"
---
  
#Here, we are opening the csv folder for the bike usage (ensure we know how to set the working directory)
bikes <- read.csv("C:/Users/mikel/OneDrive/Desktop/Assessment_2_STM4PSD/bikes.csv",header=TRUE)
bikes

#NOTE that Main Objective is to compute the Confidence Intervals (taking 95% as our assumption)
#Covered in Workshops in Weeks 4 and 5. 

#I.e. There are four types of Confidence Intervals (we have to match) for the executive 
#expectations. 

#Single Mean 
#Proportion 
#Difference in two means 
#Unpaired Difference in two means



#The average number of casual users, registered users, and total users per day
avg_casual <- mean(bikes$casual)
avg_reg <- mean(bikes$registered)
avg_total <- mean(bikes$casual+bikes$registered)



#Here, in R were are computing the 95% confidence interval for the single Means (assuming sigma is known)

interval <- function(data){
  mean(data) + c(-1,1)*1.96*sd(data)/sqrt(length(data))
}

#95% Confidence Interval for Casual users
interval(bikes$casual)

#95% Confidence Interval for Registered Users
interval(bikes$registered)

#95% Confidence Interval for All Users
interval(bikes$casual+bikes$registered)
#[1]  764.9843 1181.1942
#[1] 2935.313 3728.545
#[1] 3773.227 4836.808



#Single Means (assuming sigma is unknown) Using the t-test demonstrated in R

#Using the t test to compute the 95% Confidence Interval for the Casual users
t.test(bikes$casual , mu =avg_casual)
# [760.3079,1185.8707]


#Using the t test to compute the 95% Confidence Interval for the Registered users
t.test(bikes$registered , mu = avg_reg)
# [2926.400,3737.457]

#Using the t test to compute the 95% Confidence Interval for the Total bike users
t.test(bikes$casual+ bikes$registered , mu = avg_total)
#[3761.277,4848.759]



#Computing the Proportion 95% Confidence Interval for registered users amongst all users in R.
#Proportion of the registered users among all users in R.
prop_reg <- sum(bikes$registered)/(sum(bikes$registered)+sum(bikes$casual))

#Standard error for the registered users 
se_reg <- sqrt((prop_reg*(1-prop_reg))/(length(bikes$registered)))

#Therefore the approximate 95% confidence interval.
prop_reg + c(-1,1)*1.96*se_reg
#[0.6644142,0.8835137]

#Thus, we are 95% sure that the true probability of registered users occur between 0.66 and 0.88.



#Difference in two means Confidence Interval in usage by casual users vs. registered users.
#Paired t-test in R.

#Using the t.test and compare the usage between casual vs. registered users 
t.test(bikes$registered,bikes$casual,paired=TRUE)

#Which gives us the 95% confidence interval of [2006.980,2710.699]



#Difference of two means, unpaired t-test
#Whether there are yearly differences in bikeshare usage.


bikes.2011 <- bikes[bikes$year == 2011,]
bikes.2012 <- bikes[bikes$year == 2012,]



#Compute the total bikeshare usage from 2011 and 2012.

total_users_2011<-bikes.2011$casual+bikes.2011$registered
total_users_2012<-bikes.2012$casual+bikes.2012$registered



#Check for Yearly differences in bikeshare usage, Using t-test unpaired in R. 

t.test(total_users_2011,total_users_2012)
#[-2705.1444,-708.0699]











