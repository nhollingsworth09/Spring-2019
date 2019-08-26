import numpy as np

from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
from pyspark.sql.functions import avg, min, hour, mean, month

'''
Location coordinates

LaGuardia: 40.776911, -73.873853
John F Kennedy: 40.641482, -73.778214
Caroll Gardens: 40.679638, -73.998240
Madison Square Garden: 40.750519, -73.993437
Yankee Stadium: 40.829761, -73.926164
'''

sc = SparkContext()
spark = SparkSession(sc)

taxi = spark.read.format("CSV").option("header","true").load("/data/MSA_8050_Spring_19/7pm_1/yellow_tripdata_2014-04.csv")

original_columns = taxi.schema.names

taxi_rdd = taxi.rdd.map(tuple)
#print taxi_rdd.take(5)

#Convert coordinates to radians for distance calculations. (Latitude, Longitude)
pickups = taxi_rdd.map(lambda trip: (trip[0], np.radians(float(trip[6])), np.radians(float(trip[5]))))
#print pickups.take(5)

def pickup_loc(lat, long):
    #Distances will be calculated in Kilometers
    
    dist_LGA = np.arccos(np.sin(np.radians(40.776911)) * np.sin(lat) + np.cos(np.radians(40.776911)) * np.cos(lat) * np.cos(long - (np.radians(-73.873853)))) * 6371
    dist_JFK = np.arccos(np.sin(np.radians(40.641482)) * np.sin(lat) + np.cos(np.radians(40.641482)) * np.cos(lat) * np.cos(long - (np.radians(-73.778214)))) * 6371
    dist_CG = np.arccos(np.sin(np.radians(40.679638)) * np.sin(lat) + np.cos(np.radians(40.679638)) * np.cos(lat) * np.cos(long - (np.radians(-73.998240)))) * 6371
    dist_MSG = np.arccos(np.sin(np.radians(40.750519)) * np.sin(lat) + np.cos(np.radians(40.750519)) * np.cos(lat) * np.cos(long - (np.radians(-73.993437)))) * 6371
    dist_YS = np.arccos(np.sin(np.radians(40.829761)) * np.sin(lat) + np.cos(np.radians(40.829761)) * np.cos(lat) * np.cos(long - (np.radians(-73.926164)))) * 6371
    
    if dist_JFK < 3:
        return str("JFK")
    elif dist_LGA < 1.5:
        return str("LGA")
    elif dist_MSG < 0.5:
        return str("MSG")
    elif dist_CG < 1.5:
        return str("CG")
    elif dist_YS < 0.7:
        return str("YS")
    else:
        return str("None")

#Need to forcefully convert back to Python floats, as Numpy floats cannot be processed in .toDF()
taxi_pickups = pickups.map(lambda trip: (trip[0], float(trip[1]), float(trip[2]), pickup_loc(float(trip[1]), float(trip[2]))))
#print taxi_pickups.take(5)

pickupDF = taxi_pickups.toDF(['vendorID','pickupLat','pickupLong','pickup_location'])
#pickupDF.show(50,False)
pickupDF.groupBy('pickup_location').count().sort('count').show()
