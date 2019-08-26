rm(list=ls())
graphics.off()
require("fpp2")

################
# Question 1
################

#-- Part (a)
s <- c(rep(0,100), 10*exp(-(101:200)/20)*cos(2*pi*(101:200)/4))
x <- ts(s + rnorm(200, 0, 1))
plot(x)


#-- Part (b)
s <- c(rep(0,100), 10*exp(-(101:200)/200)*cos(2*pi*(101:200)/4))
x <- ts(s + rnorm(200, 0, 1))
plot(x)

#-- Part (c)

#The plot in part (a) relates more with the Explosion plot. They both show pure randomness (white noise) with a mean of zero. However, the Explosion series has considerably less variance with very obvious periods of high variance

#The plot in part (b) related more with the Earthquake series. Simlarly as before, the both show pure randomness (white noise) with a mean of zero. However, though the mean does not depend on time, the variance can be seen to increase with time.

###############
# Question 3
###############

#-- Part (a)

install.packages("astsa")
require("astsa")
head(oil)
head(gas)

ts.plot(oil, main = "Time Series: oil")
ts.plot(gas, main = "Time Series: gas")

# Both series show an upward trend (with a downward spike in 2009). This illustrates a non-constant mean, which violates stationarity.

#-- Part (b)

plot(diff(log(oil)), main = expression(paste("Time Series: ",nabla," log(oil)")))
plot(diff(log(gas)), main = expression(paste("Time Series: ",nabla," log(gas)")))

#The tranformation removes most of the trend data using differnces, with drastic changes in variation still present (but with less impact) in 2009.

acf(diff(log(oil)), main = expression(paste("ACF: ",nabla," log(oil)")))
acf(diff(log(gas)), main = expression(paste("ACF: ",nabla," log(gas)")))

#Before the transformation, oil and gas ACF showed very sticky data; in other words, high correlation between years. Once transformed, the ACF shows that most of the correlation has been removed (thus removing trends), but still shows some very slight cyclic behavior
