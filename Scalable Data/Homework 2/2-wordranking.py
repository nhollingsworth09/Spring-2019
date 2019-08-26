import csv
import re
import nltk
import string
#nltk.download('stopwords')
from collections import Counter
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize, RegexpTokenizer
from pyspark import SparkConf, SparkContext

conf = SparkConf().setMaster('local').setAppName('hw2')
sc = SparkContext(conf=conf)

tokenizer = RegexpTokenizer(r'\w+')
stop_words = set(stopwords.words('english'))

#-- Create k,v pairs of (rating, tokenized comment)
rating_review = sc.textFile("Amazon_Comments.csv").map(lambda line: line.split("^"))\
			.map(lambda line: (line[6], line[5]))\
			.map(lambda line: (line[0], ''.join([word for word in line[1] if word not in string.punctuation]).lower()))\
			.mapValues(lambda comment: nltk.word_tokenize(comment))\
			.mapValues(lambda comment: [word for word in comment if word not in stop_words])

#-- Merges by rating then concatenated the list of tokenized comments
ratings = rating_review.reduceByKey(lambda x,y: x+y)

#-- Returns k,v paird of (rating, list of top 10 words)
top_words = ratings.mapValues(lambda comment: Counter(comment).most_common(10))\
			.sortByKey(True, None)

#print top_words.collect()

for k,v in top_words.collect():
	print("{} star rating: {}".format(k,v))
