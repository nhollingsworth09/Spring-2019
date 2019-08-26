rm(list=ls())
graphics.off()

setwd("C:/Users/nholl/Dropbox/2019 SPRING/MSA 8150 - Machine Learning/Homework/HW3")

library(ISLR)
library(glmnet)
library(pls)
library(splines)
library(gam)

data <- read.csv(file="Fertility.csv", header=TRUE, sep=",")

train <- data[1:30,]
ytrain <- train$Fertility

test <- data[31:47,]
ytest <- test$Fertility

###################
# Question 2
###################

#-- Part (a): Lease Squares Estimate

ols.fit <- lm(Fertility ~., data = train)
#summary(ols.fit)

ols.pred <- predict(ols.fit, test[,-1])
ols.mse <- norm(as.matrix(ytest-ols.pred))

#MSE
ols.err <- mean((ols.pred-ytest)**2)
print(ols.err)

#-- Part (b): Ridge Regression

#Selecting Best Lambda
grid=10^seq(10,-2,length=100)

set.seed(1)
cv.out <- cv.glmnet(as.matrix(train[,-1]),ytrain, alpha = 0)
plot(cv.out)

bestlam <- cv.out$lambda.min

#Fitting Model
ridge.fit <- glmnet(as.matrix(train[,-1]),ytrain,alpha=0,lambda=grid)

#Predictions
ridge.pred <- predict(ridge.fit, s=bestlam, newx=as.matrix(test[,-1]))

#MSE
ridge.err <- mean((ridge.pred-ytest)**2)
print(ridge.err)

#-- Part (c): Lasso Regression

#Selecting Best Lambda
set.seed(1)
cv.out2 <- cv.glmnet(as.matrix(train[,-1]),ytrain, alpha = 1)
plot(cv.out2)

bestlam2 <- cv.out2$lambda.min

#Fitting Model
lasso.fit <- glmnet(as.matrix(train[,-1]),ytrain,alpha=1,lambda=grid)

#Predictions
lasso.pred <- predict(ridge.fit, s=bestlam2, newx=as.matrix(test[,-1]))

#MSE
lasso.err <- mean((lasso.pred-ytest)**2)
print(lasso.err)

#-- Part (d): Principle Component Regression
set.seed(5)
pcr.fit <- pcr(Fertility~., data=train,scale=TRUE,validation="CV")

validationplot(pcr.fit,val.type="MSEP")

#Predictions using optimum number of components (2)
pcr.pred <- predict(pcr.fit,test[,-1], ncomp=2)

#MSE
pcr.err <- mean((pcr.pred-ytest)**2)
print(pcr.err)

#-- Part (e)
models <- c("OLS","Ridge","LASSO","PCR")
errors <- c(ols.err, ridge.err, lasso.err, pcr.err)

as.data.frame(cbind(models, errors))

###################
# Question 3
###################
rm(list=ls())
graphics.off()

data <- read.csv(file="Auto.csv", header=TRUE, sep=",")

#-- Part (a): 6-Degree Polynomial
poly.fit <- lm(mpg~poly(horsepower,4),data=data)

hplims <- range(data$horsepower)
hp.grid <- seq(from=hplims[1],to=hplims[2])

#Predictions
poly.pred <- predict(poly.fit,newdata=list(horsepower=hp.grid),se=TRUE)
se.bands <- cbind(poly.pred$fit+2*poly.pred$se.fit,poly.pred$fit-2*poly.pred$se.fit)

#Plot
par(mfrow=c(1,1),mar=c(4.5,4.5,1,1),oma=c(0,0,4,0))
plot(data$horsepower,data$mpg,xlim=hplims,cex=.5,col="darkgrey")
title("Degree-6 Polynomial",outer=T)
lines(hp.grid,poly.pred$fit,lwd=2,col="blue")
matlines(hp.grid,se.bands,lwd=1,col="blue",lty=3)

#-- Part (b): Spline of 6 DF
spline.fit <- lm(mpg~ns(horsepower,df=6),data=data)
spline.pred <- predict(spline.fit,newdata=list(horsepower=hp.grid),se=T)

#Plotting
plot(data$horsepower,data$mpg,col="darkgray")
title("Natural Spline: DF = 6")
lines(hp.grid,spline.pred$fit,lwd=2,col="blue")
spline.bands <- cbind(spline.pred$fit+2*spline.pred$se.fit,spline.pred$fit-2*spline.pred$se.fit)
matlines(hp.grid,spline.bands,lwd=1,col="blue",lty=3)

#-- Part (c): 

train <- data[1:350,]

test <- data[351:392,]
ytest <- test$mpg

#Linear Model
lm.fit <- lm(mpg~horsepower + acceleration + year, data = train)

lm.pred <- predict(lm.fit,test[,-1])

#GAMS
gams.fit <- gam(mpg~ns(horsepower,4)+ns(acceleration,4)+year ,data=train)

gams.pred <- predict(gams.fit,test[,-1])
#MSEs
lm.err <- mean((lm.pred-ytest)**2)
gams.err <- mean((gams.pred-ytest)**2)

model <- c("OLS","GAMS")
errors <- c(lm.err,gams.err)

as.data.frame(cbind(model,errors))
