# -*- coding: utf-8 -*-

import csv
import re
import string

import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize, RegexpTokenizer
#nltk.download('stopwords') //needed if not currently installed

from collections import Counter
from functools import reduce
from pyspark import SparkConf, SparkContext
from pyspark.sql.session import SparkSession
from pyspark.sql.functions import avg

# =============================================================================
# Part (a)
# =============================================================================

##################
# HW2 Question 1
##################

conf = SparkConf().setAppName('hw3')
sc = SparkContext(conf=conf)

tokenizer = RegexpTokenizer(r'\w+')

#Recieved continued errors with '.translate()' so found alternative ways to remove punctuation thats a bit more consistent than 're.sub('\W+',' ',string)'

rating_review1 = sc.textFile("Amazon_Comments.csv").map(lambda line: line.split("^"))\
			.map(lambda line: (line[6], ''.join([word for word in line[5] if word not in string.punctuation]).lower()))

rating_review1.persist

#-- Number of Words in each review
review_lengths = rating_review1.mapValues(lambda comment: tokenizer.tokenize(comment))\
			.mapValues(lambda comment: len(comment))\
			.reduceByKey(lambda x,y: x+y)

#-- Count for each rating
review_total = rating_review1.map(lambda pair: (pair[0],1))\
			.reduceByKey(lambda x,y: x+y)

#-- Average number of words per rating
review_average = review_lengths.join(review_total).mapValues(lambda x: x[0]/x[1])\
			.sortByKey(True, None)

#print review_average.collect()

for k,v in review_average.collect():
	print("{} star rating: {}".format(k,v))


##################
# HW2 Question 2
##################

stop_words = set(stopwords.words('english'))

#-- Create k,v pairs of (rating, tokenized comment)
rating_review2 = sc.textFile("Amazon_Comments.csv").map(lambda line: line.split("^"))\
			.map(lambda line: (line[6], line[5]))\
			.map(lambda line: (line[0], ''.join([word for word in line[1] if word not in string.punctuation]).lower()))\
			.mapValues(lambda comment: nltk.word_tokenize(comment))\
			.mapValues(lambda comment: [word for word in comment if word not in stop_words])

rating_review2.persist

#-- Merges by rating then concatenated the list of tokenized comments
ratings = rating_review2.reduceByKey(lambda x,y: x+y)

#-- Returns k,v paird of (rating, list of top 10 words)
top_words = ratings.mapValues(lambda comment: Counter(comment).most_common(10))\
			.sortByKey(True, None)

#print top_words.collect()

for k,v in top_words.collect():
	print("{} star rating: {}".format(k,v))

# =============================================================================
# Part (b)
# =============================================================================

#####################################
# HW2 Question 1 - Using DataFrames
#####################################

spark   = SparkSession(sc)

rating_review3 = sc.textFile("Amazon_Comments.csv")\
                        .map(lambda line: line.split("^"))\
                        .map(lambda line: (line[6], ''.join([word for word in line[5] if word not in string.punctuation]).lower()))\
                        .mapValues(lambda comment: tokenizer.tokenize(comment))\
                        .mapValues(lambda comment: len(comment))

rating_review3.persist

ratingsDF = rating_review3.toDF(["Rating", "Length"])

#ratingsDF.show()

lengthsDF = ratingsDF.groupBy('Rating').agg(avg('Length'))

#lengthsDF.show()

for k,v in sorted(lengthsDF.collect()):
        print("{} star rating: {}".format(k,round(v)))
