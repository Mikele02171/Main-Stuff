## Q1
# (a)
library(faraway)
data(wbca)

# (b)
wbca.model = glm(cbind(Class, 1-Class) ~ ., data=wbca, family=binomial)

# (c)
wbca.model.step = step(wbca.model)

# (d)
wbca.newdata = list(Adhes=1, BNucl=1, Chrom=3, Mitos=1, NNucl=1, Thick=4, UShap=1)

output = predict(wbca.model.step, newdata=wbca.newdata, type="link", se.fit=TRUE)

eta.hat = output$fit
( standarderror = output$se.fit )

wbca.newdata.predict.linear.ci = c(eta.hat - 1.96 * standarderror, eta.hat, eta.hat + 1.96 * standarderror)

logistic = function(eta) {
    return(1 / (1 + exp(-eta)))
}

(wbca.newdata.predict.response.ci = logistic(wbca.newdata.predict.linear.ci))
# wbca.newdata.predict.response = predict(wbca.model, newdata=wbca.newdata, type="response", se.fit=TRUE)

# (e)
( wbca.predict.prob = predict(wbca.model.step, type="response") )

probtoClass = function(prob) {
    return(if (prob > 0.5) 1 else 0)
}
wbca.predict.Class = probtoClass(wbca.predict.prob)

