rm(list=ls())

#install.packages("plm")
library("plm")
library(foreign)

setwd('C:/Users/nholl/Dropbox/SPRING 2019/MSA 8200 - Econometrics/Homework/HW3')
nbasal = read.dta("~/nbasal.dta", convert.factors = FALSE)
jtrain1 = read.dta("~/jtrain1.dta", convert.factors = FALSE)

getwd()

##################
### Question 1
#################

#--- Part (a)

#- OLS Estimator
jt = jtrain1[!is.na(jtrain1$scrap),]
head(jt, 5)

sum(is.na(jt[,'d89']))

ols.fit = lm(lscrap ~ d88 + d89 + grant + grant_1 + lscrap_1, data=jt)
summary(ols.fit)

#--- Part (c)

#- Random Effects
random.fit =  plm(lscrap ~ d88 + d89 + grant + grant_1 + lscrap_1, data=jt, index=c("fcode", "year"), model="random")
summary(random.fit)

#--- Part (d)
pnorm(1.87,lower.tail = FALSE)

###################
## Question 2
##################

#nb = nbasal[!is.na(nbasal$wage),]

##= Part (c)

X = nbasal[,c('age', 'exper', 'coll', 'guard', 'forward', 'black', 'marr')]
X = cbind(X, X['exper']**2)
colnames(X) <- c('age', 'exper', 'coll', 'guard', 'forward', 'black', 'marr', 'exper_2')

R = matrix(c(0,0,0,0,0,0,1,0),1)
r = 0 
##################
## Question 4
##################

#install.packages("devtools")
#install.packages("systemfit")
#install_git("https://github.com/ccolonescu/PoEdata")

library(devtools)
library(systemfit)
library(PoEdata)

data("truffles", package="PoEdata")

#-- Part (a)

demand.ols <- lm(q ~ p + ps + di, data=truffles)
summary(demand.ols)

#-- Part (b)

p.fit<- lm(p ~ ps + di + pf, data= truffles)
p_pred <- predict(p.fit, truffles[,c('ps', 'pf', 'di')])

truf <- cbind(truffles, p_pred)


dem <- lm(q ~ p_pred + ps + di, data = truf)
summary(dem)

sup <- lm(q ~ p_pred + pf, data = truf)
summary(sup)
