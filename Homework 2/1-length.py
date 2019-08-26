import csv
import re
import nltk
import string
from functools import reduce
from pyspark import SparkConf, SparkContext
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize, RegexpTokenizer

conf = SparkConf().setMaster('local').setAppName('hw2')
sc = SparkContext(conf=conf)

tokenizer = RegexpTokenizer(r'\w+')

#Recieved continued errors with '.translate()' so found alternative ways to remove punctuation thats a bit more consistent than 're.sub('\W+',' ',string)'

rating_review = sc.textFile("Amazon_Comments.csv").map(lambda line: line.split("^"))\
			.map(lambda line: (line[6], ''.join([word for word in line[5] if word not in string.punctuation]).lower()))

rating_review.persist

#-- Number of Words in each review
review_lengths = rating_review.mapValues(lambda comment: tokenizer.tokenize(comment))\
			.mapValues(lambda comment: len(comment))\
			.reduceByKey(lambda x,y: x+y)

#-- Count for each rating
review_total = rating_review.map(lambda pair: (pair[0],1))\
			.reduceByKey(lambda x,y: x+y)

#-- Average number of words per rating
review_average = review_lengths.join(review_total).mapValues(lambda x: x[0]/x[1])\
			.sortByKey(True, None)

#print review_average.collect()

for k,v in review_average.collect():
	print("{} star rating: {}".format(k,v))


