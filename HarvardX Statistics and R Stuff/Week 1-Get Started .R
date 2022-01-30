install.packages("rafalib")
library(rafalib)
swirl()


#Week 1: Get Started HarvardX Statistics and R

First assessment: Exercises 

#Excerise 2
#Create a numeric vector containing the numbers 2.23, 3.45, 1.87, 2.11, 
#7.33, 18.34, 19.23

vector = c(2.23, 3.45, 1.87, 2.11,7.33, 18.34, 19.23)
mean(vector)

#Exercise 3
#Use a for loop to determine the value of sum(i^2) from i = 1 to 25
x = c(1:25)
count = 0

for (i in 1:25){
  count[i] = x[i]*x[i]
}
sum(count)

#Exercise 4
#The cars dataset is available in base R. 
#You can type cars to see it. Use the class() function to determine what type 
#of object is cars.

#cars --> undo # to run it.

class(cars)


#Exercise 5 to 6 (Refer from Website)


#Exercise 7
#The simplest way to extract the columns of a matrix or data.frame is using [.
#For example you can access the second column with cars[,2].

#What is the average distance traveled in this dataset?
averagecars = mean(cars[,2])

#Exercise #8

#Familiarize yourself with the which() function. 
#Which row of cars has a a distance of 85?
which(85 == c(cars[,2]))









