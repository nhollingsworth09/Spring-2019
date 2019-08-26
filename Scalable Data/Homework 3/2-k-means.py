import random
from math import sqrt
from pyspark import sql
from pyspark.sql import SQLContext
from pyspark import SparkConf, SparkContext
from pyspark.sql.session import SparkSession
from pyspark.ml import Pipeline
from pyspark.ml.clustering import KMeans
from pyspark.ml.feature import HashingTF, Tokenizer
from pyspark.ml.feature import VectorAssembler


conf = SparkConf().setMaster('local').setAppName('hw3')
sc = SparkContext(conf=conf)
spark = SparkSession(sc)

#===========================
# Part (a)
#===========================
data1 = sc.textFile('kmeans_data.txt')\
		.map(lambda line: line.split(' '))\
		.map(lambda line: [float(x) for x in line])

print data1.collect()

dataDF = data1.toDF(['idx','x','y'])
dataDF = dataDF.drop('idx')

vecAssembler = VectorAssembler(inputCols=['x','y'], outputCol="features")
vectorDF = vecAssembler.transform(dataDF)

#dataDF.show()
#vectorDF.show()

kmeans = KMeans().setK(2).setSeed(1)
model = kmeans.fit(vectorDF)

centers = model.clusterCenters()

print("Cluster Centers: ")
for center in centers:
    print(center)


#===========================
# Part (b)
#===========================

# Load and parse the data
data2 = sc.textFile('kmeans_data.txt')\
                .map(lambda line: line.split(' '))\
                .map(lambda line: [float(x) for x in line])\
                .map(lambda x: (x[1], x[2]))

#print(data2.collect())

k = 2

centroids = random.sample(data2.collect(), k)
#print('Initial Centroids: ', centroids)


def distance_k(point, k):
    if k == 0:
        dist1 = sqrt((point[0] - centroids[0][0]) ** 2 + (point[1] - centroids[0][1]) ** 2)
        return dist1
    
    elif k == 1:
        dist2 = sqrt((point[0] - centroids[1][0]) ** 2 + (point[1] - centroids[1][1]) ** 2)
        return dist2

def closest_k(dist1, dist2):
    if dist1 < dist2:
        return 1
    else:
        return 2

while True:
    
    def distance_k(point, k):
        if k == 0:
            dist1 = sqrt((point[0] - centroids[0][0]) ** 2 + (point[1] - centroids[0][1]) ** 2)
            return dist1
        
        elif k == 1:
            dist2 = sqrt((point[0] - centroids[1][0]) ** 2 + (point[1] - centroids[1][1]) ** 2)
            return dist2

    def closest_k(dist1, dist2):
        if dist1 < dist2:
            return 1
        else:
            return 2
    
        
    '''
    The following steps correspond to each MapReduce step for data_loop
    
    (1) Use functions to calculate euclidean distances from centroids
    (2) Assign the closest centroid to that point
    (3) Transform RDD to have K-mean assignment as key
    (4) ReduceBy key to find averages of each coordinate [Store in a new RDD for centroids]
    (5) Find new centroids by averaging the total x and y values for each centorid assignment
    '''

    data_loop  = data2.map(lambda x: (x[0], x[1], distance_k(x,0), distance_k(x,1)))\
                    .map(lambda x: (x[0], x[1], x[2], x[3], closest_k(x[2],x[3])))\
                    .map(lambda x: (x[4], (x[0],x[1],x[2],x[3], 1)))\
                    .reduceByKey(lambda x,y: (x[0]+y[0], x[1]+y[1], x[2]+y[2], x[3]+y[3],x[4]+y[4]))\
                    .mapValues(lambda x: (round(x[0]/x[4],2), round(x[1]/x[4],2)))


    new_centroids = data_loop.map(lambda x: (x[1][0], x[1][1])).collect()

    '''
    Error terms are calculated as the distance between the old and new centroids. As the distances decrease, we approach the true centroids. If we do not reach out threshold of a difference of less than 0.5, the loop repeats to calculate new centroids once again.
    '''
    
    dist1 = sqrt((new_centroids[0][0] - centroids[0][0]) ** 2 + (new_centroids[0][1] - centroids[0][1]) ** 2)
    dist2 = sqrt((new_centroids[1][0] - centroids[1][0]) ** 2 + (new_centroids[1][1] - centroids[1][1]) ** 2)
    
    currentError = (dist1 + dist2)/2
            
    if currentError < 0.5:
        break
    else:
        centroids = new_centroids

print('Initial Centroids: ', centroids)
print('Final Cluster Centroids: ', centroids)


