rm(list=ls())

setwd("C:/Users/nholl/Dropbox/SPRING 2019/MSA 8150 - Machine Learning/Homework/HW2")

#install.packages('Metrics')
#install.packages('caret')
library(Metrics)
library(ISLR)
library(boot)
library(MASS)
library(class)
library(caret)

################
## Question 1 ##
################

# Part (a)

# Part (b)

values <- c(0.3057, 0.7227, 1.1566, 2.8622, 1.3588, 0.5377, 0.4336, 0.3426, 3.5784, 2.7694)
keys <- 1:10

data <- data.frame(keys,values)

theta.ml <- (4*length(values))/sum(values)

length(data[,1])

# Boot Function
#######################################################
boot.fn = function(df, index){
  return(4*length(df[,1])/sum(df[index,2]))
}
######################################################
set.seed(1)
boot.stats <- boot(data, boot.fn, 50000)
print(boot.stats)

# Part (c)

set.seed(1)
boot.stats2 <- boot(data, boot.fn, 1000)
print(boot.stats2)


################
## Question 3 ##
################

data_heart <- read.csv("HeartData.csv")
#head(data_heart)
#str(data_heart)

train <- data_heart[1:200,]
test <- data_heart[201:297,]

#########
# Part A
#########

################## Linear Regression

features <- colnames(train)
features <- features[features!='num']

glm.fit <- glm(reformulate(features, response = 'num'), data = train, family = 'binomial')
summary(glm.fit)

glm.coef <- summary(glm.fit)$coef
glm.coef[order(glm.coef[,4], decreasing = TRUE),]

#Accuracy

glm.prob <- predict(glm.fit, newdata = test, type = 'response')
#length(glm.prob)

glm.pred <- rep('0', 97)
glm.pred[glm.prob > 0.5] <- '1'
glm.pred

mean(glm.pred == test$num)

accuracy(test$num, glm.pred)

########### LDA ############
lda.fit <- lda(num ~ ., data = train)
lda.fit

  #Accuracy
lda.pred <- predict(lda.fit, newdata = test)
lda.class <- lda.pred$class

accuracy(test$num, lda.class)

########## QDA #############
qda.fit <- qda(num~.,data = train)
qda.fit

  #Accuracy
qda.class <- predict(qda.fit, newdata = test)$class

accuracy(test$num, qda.class)

########### KNN ############

n <- c(1,5,10)
knn_optimum <- function (train, test, n) {
 
  models <- data.frame(matrix(ncol = 2, nrow = length(n)))
  names(models) <- c('K-NN', 'Accuracy')  
  row <- 1
  
  for (i in n){
    knn.fit <- knn(train,test,train[,'num'] ,k=i)
    
    models[row,1] <- i
    models[row,2] <- accuracy(test$num, knn.fit)
    
    row <- row + 1
  }
  
  print(models)
}

set.seed(1)
knn_optimum(train, test, n)

plot(knn_optimum(train, test, n))
abline(v = 5, lty=2)

########## Evaluation #############


###########
# Part B
###########

f <- c("sex", "cp", "fbs", "slope", "exang", "ca", "thal")

to_factor <- function(df, features){
  for (i in features){
   df[,i] <- factor(df[,i])
  }
  
  print(df)
}

train.cat <- to_factor(train, f)
#str(train.cat)

test.cat <- to_factor(test, f)
#str(test.cat)

################## Linear Regression

features <- colnames(train.cat)
features <- features[features!='num']

glm.fit <- glm(reformulate(features, response = 'num'), data = train.cat, family = 'binomial')
summary(glm.fit)

glm.coef <- summary(glm.fit)$coef
glm.coef[order(glm.coef[,4], decreasing = TRUE),]

#Accuracy

glm.prob <- predict(glm.fit, newdata = test.cat, type = 'response')
#length(glm.prob)

glm.pred <- rep('0', 97)
glm.pred[glm.prob > 0.5] <- '1'
glm.pred

mean(glm.pred == test.cat$num)

accuracy(test.cat$num, glm.pred)

########### LDA ############
lda.fit <- lda(num ~ ., data = train.cat)
lda.fit

#Accuracy
lda.pred <- predict(lda.fit, newdata = test.cat)
lda.class <- lda.pred$class

accuracy(test$num, lda.class)

########## QDA #############
qda.fit <- qda(num~.,data = train.cat)
qda.fit

#Accuracy
qda.class <- predict(qda.fit, newdata = test.cat)$class

accuracy(test.cat$num, qda.class)

########### KNN ############

n <- c(1,5,10)
knn_optimum <- function (train, test, n) {
  
  models <- data.frame(matrix(ncol = 2, nrow = length(n)))
  names(models) <- c('K-NN', 'Accuracy')  
  row <- 1
  
  for (i in n){
    knn.fit <- knn(train,test,train[,'num'] ,k=i)
    
    models[row,1] <- i
    models[row,2] <- accuracy(test$num, knn.fit)
    
    row <- row + 1
  }
  
  print(models)
}

set.seed(1)
knn_optimum(train.cat, test.cat, n)

plot(knn_optimum(train.cat, test.cat, n))
abline(v = 5, lty=2)

########## Evaluation #############

f <- c("sex", "cp", "fbs", "slope", "exang", "ca", "thal")

to_factor <- function(df, features){
  for (i in features){
    df[,i] <- factor(df[,i])
  }
  
  print(df)
}

data.cat <- to_factor(data_heart, f)
#str(data.cat)

##########
# Part C
##########


################## Linear Regression

#- LOOCV

trControl <- trainControl(method = "LOOCV", savePredictions = 'all')
glm.fit.loocv <- train(factor(num)~., data = data.cat, family = 'binomial', method = 'glm', trControl = trControl)

  #Accuracy
glm.fit.loocv$results[2]


#- 10-Fold CV
set.seed(1)
trControl <- trainControl(method = "cv", number = 10, savePredictions = 'all')
glm.fit.10 <- train(factor(num)~., data = data.cat, family = 'binomial', method = 'glm', trControl = trControl)

  #Accuracy
glm.fit.10$results[2]

########### LDA ############

#- LOOCV
set.seed(1)
trControl <- trainControl(method = "LOOCV", savePredictions = 'all')
lda.fit.loocv <- train(factor(num)~., data = data.cat, method = 'lda', trControl = trControl)

#Accuracy
lda.fit.loocv$results[2]


#- 10-Fold CV
set.seed(1)
trControl <- trainControl(method = "cv", number = 10, savePredictions = 'all')
lda.fit.10 <- train(factor(num)~., data = data.cat, method = 'lda', trControl = trControl)

#Accuracy
lda.fit.10$results[2]


########## QDA #############


#- LOOCV
set.seed(1)
trControl <- trainControl(method = "LOOCV", savePredictions = 'all')
qda.fit.loocv <- train(factor(num)~., data = data.cat, method = 'qda', trControl = trControl)

#Accuracy
qda.fit.loocv$results[2]


#- 10-Fold CV
set.seed(1)
trControl <- trainControl(method = "cv", number = 10, savePredictions = 'all')
qda.fit.10 <- train(factor(num)~., data = data.cat, method = 'qda', trControl = trControl)

#Accuracy
qda.fit.10$results[2]


