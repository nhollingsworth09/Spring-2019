#install.packages("lubridate")
library(lubridate)
graphics.off()
setwd('C:/Users/nholl/Dropbox/2019 SPRING/MSA 8200 - Econometrics/Homework/HW5')

#########################################################
#####             Question 4
#########################################################

#=========== Setting up data for analysis

sales = readxl::read_xls("sales.xls")

#- Reformat into YYYY-MM
sales$`Sales by Month` = format(as.Date(sales$`Order Date`), "%Y-%m")

#- Group and sum by month
sales_ByMonth = aggregate(sales$Sales, by=list(sales$`Sales by Month`), FUN=sum)
colnames(sales_ByMonth) = c('Month', 'Sales')
head(sales_ByMonth)

#- Create timeseries
salesTimeSeries <- ts(sales_ByMonth$Sales, start = 2014, frequency = 12)


#=========== Data Analysis and Transformation

# The ACF for the last 4 years shows that the series is non-stationary. Additionally, fitting a trend line shows an upward trend in sales.
trend_fit <- lm(salesTimeSeries ~ time(salesTimeSeries),na.action=NULL)
plot(salesTimeSeries, ylab="Sales", main = 'Sales By Month')
abline(trend_fit, col='red')

acf(salesTimeSeries,48)
pacf(salesTimeSeries,48)

# By decomposing the series, we confirm non-stationality in 'trend' (mean is not constant) and 'seasonal' 
decomposedSales <- decompose(salesTimeSeries)
plot(decomposedSales)

#-- Removing Seasonality and Trend (No Log)
seasons = as.factor(round(time(salesTimeSeries)-floor(time(salesTimeSeries)),2))
season.fit = lm(salesTimeSeries~seasons)

par(mfrow=c(1,1))
salesTimeSeries.sa <- salesTimeSeries - season.fit$fitted.values
plot(salesTimeSeries.sa)

detrended_noLog = diff(salesTimeSeries.sa)

#-- Removing Seasonality and Trend (Log)
detrended_Log = diff(log(salesTimeSeries))

# Compare Log vs NoLog
par(mfrow=c(2,1))
plot.ts(detrended_noLog, main = 'No Log')
plot.ts(detrended_Log, main = 'Log')

acf2(detrended_noLog, 46)
acf2(detrended_Log, 46)

#After detrending, both PACFs show an AR(2) model would be ideal, but we'll try AR(1), AR(2), MA(1), and MA(2)


#===========  Modeling and Diagnosis

sarima(detrended_Log,1,0,0) #AR(1)
sarima(detrended_Log,2,0,0) #AR(2)
sarima(detrended_Log,0,0,1) #MA(1)
sarima(detrended_Log,0,0,2) #MA(2)

sarima(detrended_noLog,1,0,0) #AR(1)
sarima(detrended_noLog,2,0,0) #AR(2)
sarima(detrended_noLog,0,0,1) #MA(1)
sarima(detrended_noLog,0,0,2) #MA(2)

# After analyzing each model, it can be seen that AR(2) for both Log and noLog values creates the lowest p-values for the Ljung-Bix statistic (showing little correlation between lags) and normality in the error term.

ar.Log = arima(detrended_Log, c(2,0,0))
ar.noLog = arima(detrended_noLog, c(2,0,0))

ar.Log$coef
ar.noLog$coef

# Because we are comparing models based on 'log(sales)' vs 'sales', we can look at the coefficients to identify consistency. Coefficients seem to be very similar, thus I will procees with noLog values as they are easier to interpret.

#===========  Prediction (predict he sales for the first half of 2018)

pred = predict(ar.noLog, n.ahead =  6)

par(mfrow=c(1,1))
ts.plot(detrended_noLog,pred$pred,col=1:2,xlim=c(2014,2019),ylab="Sales", main = 'Sales Prediction for 2018')
