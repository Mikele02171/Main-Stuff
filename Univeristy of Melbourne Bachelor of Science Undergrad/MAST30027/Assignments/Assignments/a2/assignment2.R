library(dplyr)

## Read data
data = read.csv("assign2.txt", sep=" ")

## Define problems:
# 1. H0: chimpanzee is same as human: almost always prosocial
#    H1: chimpanzee is not prosocial
# 2. H0: Each chimpanzee is not prrosocial, i.e. no difference between having placebo or not
#    H1: Each chimpanzee is prrosocial, i.e. difference between placebo set
# 3. H0: Chimpanzee population is not prrosocial, i.e. no difference between having placebo or not
#    H1: Chimpanzee population is prrosocial, i.e. difference between placebo set

# Two types of analysis
# 1: A binomial model of factor level
# 2: Test of independence

## Process data
# Create new dataset on if prosocial
data$pulled_prosocial = (data$prosoc_left == data$pulled_left)
data$const = 1
# Aggregate data based on each individual
data.aggregated = aggregate(.~actor+condition+pulled_prosocial, sum, d=data)

## Plot data
# Plot the individual plot
interaction.plot(data$condition, data$actor, data$pulled_prosocial)
interaction.plot(data$prosoc_left, data$actor, data$pulled_prosocial)
# Three upward, one downward, three neutral


## Fit the model
# The binomial model
# Try with all factors, (not including pulled_left as it's not something we want to study)
data.bmodel = glm(cbind(pulled_prosocial, 1-pulled_prosocial)~factor(actor)+
                    factor(condition)+factor(prosoc_left), data=data, 
                  family = "binomial")
summary(data.bmodel)
data.bmodel.step = step(data.bmodel)
summary(data.bmodel.step)
# Check mean
data.bmodel.step.predict = predict(data.bmodel.step, type="link", se.fit=TRUE, newdata=data[1,])
# Check conf interval (link)
critval <- 1.96 ## approx 95% CI
upr <- data.bmodel.step.predict$fit + (critval * data.bmodel.step.predict$se.fit)
lwr <- data.bmodel.step.predict$fit - (critval * data.bmodel.step.predict$se.fit)
fit <- data.bmodel.step.predict$fit
data.frame(upr, fit, lwr)
# Check conf interval (response)
f = data.bmodel$family$linkinv
data.frame(f(upr), f(fit), f(lwr))
# Check residuals
plot(residuals(data.bmodel.step) ~ predict(data.bmodel.step, type="link"),
     xlab=expression(hat(eta)), ylab="Deviance residuals")
# Check overdispersion
# Estimate Phi
n = dim(data)[1]
p = 2
(data.bmodel.step.phihat = sum(residuals(data.bmodel.step, type = "pearson")^2)/(n-p))
# The value is exactly 1, so no overdispersion

# Try independence test
# Phrase test like this:
#     Factor1: isProsocial
#     Factor2: Conditioned
#     Factor3: The chimp ID
#     (Potential Factor4): Left right handle
data.aggregated.pmodel1 = glm(const ~ actor + condition + pulled_prosocial, 
                              data = data.aggregated, family=poisson)
summary(data.aggregated.pmodel1)
# Test independence
deviance(data.aggregated.pmodel1)
df.residual(data.aggregated.pmodel1)
pchisq(deviance(data.aggregated.pmodel1), 
       df=df.residual(data.aggregated.pmodel1), lower.tail = FALSE)
# Close to 1, so we conclude independent

# Use table
data.aggregated.xtabs1 <- xtabs(const ~ actor + condition + pulled_prosocial, 
                                data = data.aggregated)
summary(data.aggregated.xtabs1)

### Additional thing: Test for handedness
# Investigate if the side of lever the chimpanzee pulled depends on the condition
## Plot
interaction.plot(data$actor, data$condition, data$pulled_left)
interaction.plot(data$condition, data$actor, data$pulled_left)
# Difference in individual
## Model
# Null model
data.handedness.bmodel1.step = step(data.handedness.bmodel1)
summary(data.handedness.bmodel1.step)
# Full model
data.handedness.bmodel1 = glm(pulled_left ~ factor(actor) + factor(condition),
                              data = data, family=poisson)
summary(data.handedness.bmodel1)
# Condition doesn't seem relevant at all, but actor is pretty important
# Step model 
data.handedness.bmodel1.step = step(data.handedness.bmodel1)
summary(data.handedness.bmodel1.step)
# Actor is significant, at least some of the actors are definitely handed. (1,2,7, potentially 6 to be precise)
