## Tutorial 7
beef <- read.csv("data/beef.csv")

# (a)
pairs(beef)
# Yes, there are some evidence of heteoskesdasticity in yes particular against size and val.
# We could try to use log of size and val at the moment

# (b)
# FORWARD TESTING
null <- lm(yes ~ 1, data=beef)
add1(null, scope= ~. + big + prin+ size + val + live + sale, test="F")

model1 <- lm(yes ~ 1 + size, data=beef)
add1(model1, scope=~. + big + prin + val + live + sale, test="F")

# No more variable to add due to significant level > -0.05

# BACKWARD TESTING
model <- lm(yes ~ ., data = beef)
drop1(model, scope = ~., data=beef, test="F")

model1 <- lm(yes ~.-big, data=beef)
drop1(model1, scope=~., data=beef, test="F")

model2 <- lm (yes ~ prin+size+live+sale, data=beef)
drop1(model2, scope=~., data=beef, test="F")

model3<- lm(yes ~ size+live+sale, data=beef)
drop1(model3, scope=~., data=beef, test="F")

# (c)
basemodel <- lm(yes ~ 1, data=beef)
model <- step(basemodel, scope=~.+big+prin+size+val+live+sale)

# (d)
model1 <- lm(yes ~ size + live + sale + prin + size*sale, data=beef)
model2 <- step(model1, scope=~.)

# This model has better AIC compare than the one in number c

# (e)

