install.packages("foreign")
install.packages("AER")
require(foreign)
require("AER")
require("MASS")
require("Matrix")

setwd("C:/Users/nholl/Dropbox/SPRING 2019/MSA 8200 - Econometrics/Homework/HW2")


rm(list=ls())
df = read.dta("bwght.dta",convert.factors = FALSE)

head(df)

###################################################################

##--- Question 3: Part C

#- OLS
fit_OLS <- lm(lbwght ~ male + parity + lfaminc + packs, data = df)
summary(OLS)


#- 2SLS
fit_2SLS <- ivreg(lbwght ~ male + parity + lfaminc + packs | male + parity + lfaminc + cigprice, data = df)
summary(fit_2SLS)



##--- Question 3: Part D

packs_red <- lm(packs ~  male + parity + lfaminc + cigprice, data = df)
summary(packs_red)

##--- Question 3: Part E

###########
# DWL Test
###########

y = df$lbwght
N = length(y)
K = 5
X = cbind(rep(1,N),df$male,df$parity,df$lfaminc, df$packs) ## original regressors
Z = cbind(rep(1,N),df$male,df$parity,df$lfaminc, df$packs, df$cigprice) ## the instrument variables
#Z = cbind(rep(1,N),mroz$exper,mroz$expersq,mroz$huseduc)  ## the instrument variables

## X_hat = Pz(X) = Z(Z'Z)^{-1}Z'X
X_hat = Z %*% solve(t(Z)%*%Z) %*% t(Z) %*% X
beta_2SLS = solve(t(X_hat) %*% X_hat) %*% (t(X_hat) %*% y)
beta_OLS = solve(t(X) %*% X) %*% (t(X) %*% y)

## note: u_hat and sigma^2_hat are always calculated using the OLS regression
u_hat = y - X%*%solve(t(X) %*% X) %*% (t(X) %*% y)
sigma2_hat = sum(u_hat^2)/(N-K)

AVar_diff = (solve(t(X_hat) %*% X_hat) - solve(t(X) %*% X))*sigma2_hat
beta_diff = beta_2SLS - beta_OLS
rankMatrix(AVar_diff) ## the degree of freedom for the test, also is the # of possible endogeneous variables

DWH = t(beta_diff) %*% ginv(AVar_diff) %*% beta_diff
p_value = pchisq(DWH,df=1,lower.tail=FALSE)

p_value
####################################################################



