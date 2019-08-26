#install.packages("lubridate")
library(lubridate)
graphics.off()
setwd('C:/Users/nholl/Dropbox/2019 SPRING/MSA 8200 - Econometrics/Homework/HW5')


#########################################################
#####             Question 2
#########################################################

library(astsa)
head(cmort)

# Part(a) -- Plot the original series.
plot(decompose(cmort))

plot(cmort,ylab = "Mortality",lwd=1)
acf(cmort)
pacf(cmort)

#The ACF shows a dissipating autocorrelation between lags, which is ideal for an AR model.

# Part(b) -- Fit an AR(2) model
n = length(cmort)
mu = mean(cmort)

gamma0_hat = sum((cmort-mu)^2)/n
gamma1_hat = sum((cmort[-1]-mu)*(cmort[-n]-mu))/n
gamma2_hat = sum((cmort[-(1:2)]-mu)*(cmort[-((n-1):n)]-mu))/n
rho1_hat = gamma1_hat/gamma0_hat
rho2_hat = gamma2_hat/gamma0_hat

R = matrix(c(1,rho1_hat,rho1_hat,1),2)
b = c(rho1_hat,rho2_hat)
phi_hat = solve(R)%*%b
phi_hat

# Part(c) -- Provide the asymtopic covariance matrix

sigma2_w = as.numeric(gamma0_hat*(1-t(b)%*%phi_hat))
sigma2_w

Gamma = R*gamma0_hat
(sigma2_w/n) * solve(Gamma)
