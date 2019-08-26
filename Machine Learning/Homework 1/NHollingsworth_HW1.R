rm(list = ls()) 
graphics.off()

setwd("C:/Users/nholl/Dropbox/SPRING 2019/MSA 8150 - Machine Learning/Homework/HW1")


#========== Importing Data ==============

#Original Data
grav <- read.csv('GravityForce.csv')
head(grav)

#Data with Log Values
grav2 <- cbind(grav, log(grav$MASS1), log(grav$MASS2), log(grav$DISTANCE), log(grav$FORCE))

names <- append(colnames(grav), c('LOG_MASS1','LOG_MASS2','LOG_DISTANCE','LOG_FORCE'))
colnames(grav2) <- names

head(grav2)


########################################################
####    Question 2
#######################################################

train <- grav2[1:200,]
#nrow(train)
test <- grav2[201:240,]
test.y <- grav2[201:240, 4]
test.y.log <- grav2[201:240, 8]
#nrow(test)

#============ Part (a) ===============

M1 <- lm(FORCE ~ MASS1 + MASS2 + DISTANCE, data = train)
summary(M1)

#Beta Coefficients
beta0 <- coef(M1)[1]
beta1 <- coef(M1)[2]
beta2 <- coef(M1)[3]
beta3 <- coef(M1)[4]

cbind(beta0,beta1,beta2,beta3)

#Standard Errors
se0 <- coef(summary(M1))[1,2]
se1 <- coef(summary(M1))[2,2]
se2 <- coef(summary(M1))[3,2]
se3 <- coef(summary(M1))[4,2]

cbind(se0,se1,se2,se3)[2]

#Confidence Intervals: 95%
confint(M1, level = .95)

#=========== Part (c) ===============

M1_pred <- predict(M1, test)

E1 <- dist(rbind(M1_pred, test.y), method='euclidean')
E1


#=========== Part (d) ===============

M2 <- lm(LOG_FORCE ~ LOG_MASS1 + LOG_MASS2 + LOG_DISTANCE, data = train)
summary(M2)$coefficients

#Beta Coefficients
gamma0 <- coef(M2)[1]
alpha1 <- coef(M2)[2]
alpha2 <- coef(M2)[3]
alpha3 <- coef(M2)[4]

cbind(gamma0,alpha1,alpha2,alpha3)

#Standard Errors
se0 <- coef(summary(M2))[1,2]
se1 <- coef(summary(M2))[2,2]
se2 <- coef(summary(M2))[3,2]
se3 <- coef(summary(M2))[4,2]

cbind(se0,se1,se2,se3)

#Confidence Intervals: 95%
confint(M2, level = .95)

#=========== Part (e) ===============

M2_pred <- predict(M2, test)

E2 <- dist(rbind(exp(M2_pred), test.y), method='euclidean')
E2

#=========== Part (f) ===============

M3 <- lm(LOG_FORCE ~ LOG_MASS1 + LOG_MASS2 + LOG_DISTANCE + DISTANCE, data = train)
summary(M3)

#Beta Coefficients
gamma0 <- coef(M3)[1]
alpha1 <- coef(M3)[2]
alpha2 <- coef(M3)[3]
alpha3 <- coef(M3)[4]
alpha4 <- coef(M3)[5]

cbind(gamma0,alpha1,alpha2,alpha3,alpha4)

#Standard Errors
se0 <- coef(summary(M3))[1,2]
se1 <- coef(summary(M3))[2,2]
se2 <- coef(summary(M3))[3,2]
se3 <- coef(summary(M3))[4,2]
se4 <- coef(summary(M3))[5,2]

cbind(se0,se1,se2,se3,se4)

#Confidence Intervals: 95%
confint(M3, level = .95)

#=========== Part (g) ===============

M3_pred <- predict(M3, test)
E3 <- dist(rbind(exp(M3_pred), test.y), method = 'euclidean')
E3


#=========== Part (h) ===============

rbind(c("E1",E1[1]),c("E2", E2[1]),c("E3", E3[1]))

########################################################
####    Question 3
#######################################################

rm(list=ls())

p <- read.csv('Polarization.csv')
p2 <- cbind(p,(p$TEMP)^2,(p$TEMP)^3,(p$TEMP)^4,(p$TEMP)^5,(p$TEMP)^6,(p$TEMP)^7,(p$TEMP)^8,(p$TEMP)^9,(p$TEMP)^10)
colnames(p2) <- append(colnames(p), c("TEMP.2", "TEMP.3","TEMP.4","TEMP.5","TEMP.6","TEMP.7","TEMP.8","TEMP.9","TEMP.10"))
head(p2,3)

train <- p2[1:500,]
test <- p2[501:1100,]
test.y <- p2[501:1100,2]

#=========== Part (a) ===============

f1 <- lm(FIELD ~ TEMP + TEMP.2 + TEMP.3 + TEMP.4 + TEMP.5 + TEMP.6 + TEMP.7 + TEMP.8 + TEMP.9 + TEMP.10,data = train)
summary(f1)

confint(f1, level = .95)

#=========== Part (b) ===============

f1_pred <- predict(f1, test)

E1 <- dist(rbind(f1_pred, test.y), method = 'euclidean')
E1

#=========== Part (C) ===============

f2 <- lm(FIELD ~ TEMP.3 + TEMP.6, data = train)
summary(f2)

#Beta Coefficients
beta0 <- coef(f2)[1]
beta3 <- coef(f2)[2]
beta6 <- coef(f2)[3]

cbind(beta0,beta3,beta6)

#Standard Errors
se0 <- coef(summary(f2))[1,2]
se3 <- coef(summary(f2))[2,2]
se6 <- coef(summary(f2))[3,2]

#Confidence Intervals
confint(f2, level = .95)

f2_pred <- predict(f2, test)
E2 <- dist(rbind(f2_pred, test.y), method = 'euclidean')
E2

#=========== Part (d) ===============

optimize <- function (x) {
  #Get features excluding the response feature
  names <- colnames(x)[colnames(x) != 'FIELD']
  
  #Continue loop until all features have a p-value < 0.01
  repeat {
    #Build model
    model <- lm(reformulate(names, response = 'FIELD'), data = x)
    
    #How many features were in the regression?
    rows <- nrow(coef(summary(model)))
    
    #Identify which features show insignifcance compared to 0
    not_sig <- as.vector(coef(summary(model))[2:rows,4] > 0.01)
    
    if (sum(not_sig) == 0 | is.null(not_sig) == TRUE) {
      #If no insignificant features, break loop
      break
    } else {
      #Get which feature has the largest p-value
      p_values <- coef(summary(model))[2:rows,4]
      max_p <- names(p_values[which.max(p_values)])
      
      #And remove it. Rerun model with features left.
      names <- setdiff(names, max_p)
    }
  }
  
  return(model)
}

f3 <- optimize(train)
summary(f3)

#=========== Part (e) ===============

f3_pred <- predict(f3, test)

E3 <- dist(rbind(f3_pred, test.y), method = 'euclidean')
E3

rbind(c("E1",E1[1]),c("E2", E2[1]),c("E3", E3[1]))

