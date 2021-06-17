library (datasets)
data(iris)
View(iris) 

unique(iris$Species)

#install.packages("GGally", repos = "https://cran.r-project.org", 
#type= "source") run in Console. #After install, click on packages and select 
# GGally 
library(GGally)
ggpairs(iris, mapping=ggplot2::aes(colour = Species))