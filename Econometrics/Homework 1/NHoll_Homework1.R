rm(list=ls())
setwd("C:/Users/nholl/Dropbox/SPRING 2019/MSA 8200 - Econometrics/Homework/HW1")

invest = read.table("invest.txt", header = TRUE)
head(invest)

# Questiion 1


########################################
#     Homoskedasticity - R Code
#######################################

investfit = lm(Investment ~ Q + Cash + Debt, data = invest)
summary(investfit)

########################################
#     Homoskedasticity - By Hand
#######################################

y = invest$Investment
N = length(y)
K = ncol(invest)

X = cbind(rep(1,N), invest$Q, invest$Cash, invest$Debt)

beta_hat = solve(t(X)%*%X)%*%(t(X)%*%y)
beta_hat

y_hat = X%*%beta_hat
u_hat = y - y_hat
sigma2_hat = sum(u_hat^2)/(N-K)

AVar_beta_hat = sigma2_hat*solve(t(X)%*%X)
sqrt(diag(AVar_beta_hat))

########################################
#     Heteroskedasticity Robust - By Hand
#######################################

AVar_robust = solve(t(X)%*%X) %*% (t(X)%*% (X*c(u_hat)^2)) %*% solve(t(X)%*%X) * (N)/(N-K)
sqrt(diag(AVar_robust))


# Question 2

rm(list=ls())
nerlove = read.table("Nerlove.txt", header = TRUE)
head(nerlove)


nerlovefit = lm(log(nerlove$Cost) ~ log(nerlove$output) + log(nerlove$Plabor) + log(nerlove$Pcapital) + log(nerlove$Pfuel))
summary(nerlovefit)
 
########################################
#     Heteroskedasticity Robust - By Hand
#######################################

y = log(nerlove$Cost)
N = length(y)
K = ncol(nerlove)

X = cbind(rep(1,N), log(nerlove$output), log(nerlove$Plabor), log(nerlove$Pcapital), log(nerlove$Pfuel))

beta_hat = solve(t(X)%*%X)%*%(t(X)%*%y)
beta_hat

y_hat = X%*%beta_hat
u_hat = y - y_hat
sigma2_hat = sum(u_hat^2)/(N-K)

AVar_robust = solve(t(X)%*%X) %*% (t(X)%*% (X*c(u_hat)^2)) %*% solve(t(X)%*%X) * (N)/(N-K)
sqrt(diag(AVar_robust))

#Part B
R = matrix(c(0,0,1,1,1), 1)
wald = t(R%*%beta_hat-1) %*% solve(R%*%AVar_robust%*%t(R)) %*% (R%*%beta_hat-1)

p_wald = pchisq(wald,df=3,lower.tail = FALSE)
p_wald
