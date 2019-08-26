import numpy as np
from pyspark.sql.functions import col
from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
from pyspark.sql.functions import unix_timestamp
from pyspark.sql.functions import from_unixtime
from pyspark.sql.functions import avg, min, hour, mean, month, to_timestamp
from pyspark.sql.functions import dayofmonth, dayofweek, dayofyear, weekofyear
from pyspark.sql.types import StructField, StructType
from pyspark.sql.types import LongType, StringType, IntegerType, FloatType, TimestampType


'''
Location coordinates

LaGuardia: 40.776911, -73.873853
John F Kennedy: 40.641482, -73.778214
Caroll Gardens: 40.679638, -73.998240
Madison Square Garden: 40.750519, -73.993437
Yankee Stadium: 40.829761, -73.926164
'''

#=============== Initialize Environment =============== 

sc = SparkContext()
spark = SparkSession(sc)

#=============== Define Schema for CSV Import =========

time_format = "yyyy-MM-dd HH:mm:ss"

schema = StructType([StructField("vendor_id", StringType()),
                    StructField("pickup_datetime", TimestampType()),
                    StructField("dropoff_datetime", TimestampType()),
                    StructField("passenger_count", IntegerType()),
                    StructField("trip_distance", FloatType()),
                    StructField("pickup_longitude", FloatType()),
                    StructField("pickup_latitude", FloatType()),
                    StructField("rate_code", StringType()),
                    StructField("store_and_fwd_flag", StringType()),
                    StructField("dropoff_longitude", FloatType()),
                    StructField("dropoff_latitude", FloatType()),
                    StructField("payment_type", StringType()),
                    StructField("fare_amount", FloatType()),
                    StructField("surcharge", FloatType()),
                    StructField("mta_tax", FloatType()),
                    StructField("tip_amount", FloatType()),
                    StructField("tolls_amount", FloatType()),
                    StructField("total_amount", FloatType())])


taxi = (spark.read.schema(schema).option("header", "true")
            .option("mode", "DROPMALFORMED")
            .csv('taxi4_05sample.csv'))

'''
#taxi = spark.read.format("CSV").option("header","true").load("taxi4_05sample.csv")

#taxi2 = taxi.select(' pickup_datetime', dayofweek(to_timestamp(' pickup_datetime', time_format)).alias('date_pickup'))

taxi2 = taxi.select('pickup_datetime', dayofweek('pickup_datetime').alias('date_pickup'))

#--- Change Schema
#taxi = spark.createDataFrame(taxi.rdd, schema)

#taxi.printSchema() 
taxi2.show()

original_columns = taxi.schema.names
#print original_columns

#taxi_rdd = taxi.rdd.map(tuple)
#print taxi_rdd.take(5)
'''
original_columns = taxi.schema.names
print original_columns

#========== Initial Aggregations/Counts =======
'''
#-- Trips per Month
per_month = taxi.select('pickup_datetime', month('pickup_datetime').alias('date_pickup')).groupBy('date_pickup').count().sort('date_pickup')

per_month.show()

#-- Trips per Week

per_week = taxi.select('pickup_datetime', weekofyear('pickup_datetime').alias('date_pickup')).groupBy('date_pickup').count().sort('date_pickup')

per_week.show()

#-- Trips per Day
per_day = taxi.select('pickup_datetime', dayofweek('pickup_datetime').alias('date_pickup')).groupBy('date_pickup').count().sort('date_pickup')

per_day.show()

#-- Trips per Hour
per_hour = taxi.select('pickup_datetime', hour('pickup_datetime').alias('date_pickup')).groupBy('date_pickup').count().sort('date_pickup')

per_hour.show()
'''
#========== User Defined Functions =============

#-- Convert to radians
def to_radians_udf(x):
	return float(np.radians(x))


#Convert coordinates to radians for distance calculations. (Latitude, Longitude)
#pickups = taxi_rdd.map(lambda trip: (trip[0], np.radians(float(trip[6])), np.radians(float(trip[5]))))
#print pickups.take(5)


#-- Locator using corrdinated (distances will be calculated in Kilometers)
def locateNYC_udf(lat, lon):
    
    dist_LGA = np.arccos(np.sin(np.radians(40.776911)) * np.sin(lat) + np.cos(np.radians(40.776911)) * np.cos(lat) * np.cos(lon - (np.radians(-73.873853)))) * 6371
    dist_JFK = np.arccos(np.sin(np.radians(40.641482)) * np.sin(lat) + np.cos(np.radians(40.641482)) * np.cos(lat) * np.cos(lon - (np.radians(-73.778214)))) * 6371
    dist_CG = np.arccos(np.sin(np.radians(40.679638)) * np.sin(lat) + np.cos(np.radians(40.679638)) * np.cos(lat) * np.cos(lon - (np.radians(-73.998240)))) * 6371
    dist_MSG = np.arccos(np.sin(np.radians(40.750519)) * np.sin(lat) + np.cos(np.radians(40.750519)) * np.cos(lat) * np.cos(lon - (np.radians(-73.993437)))) * 6371
    dist_YS = np.arccos(np.sin(np.radians(40.829761)) * np.sin(lat) + np.cos(np.radians(40.829761)) * np.cos(lat) * np.cos(lon - (np.radians(-73.926164)))) * 6371
    
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

#-- Registering UDFs with PySpark
to_radians = spark.udf.register("to_radians", to_radians_udf, FloatType())
locateNYC = spark.udf.register("locateNYC", locateNYC_udf, StringType())

#================== Transform coordinates to radians ============

taxi_temp1 = taxi.select(col('pickup_datetime'),
	to_radians(col('pickup_longitude')).alias('pickup_long_rads'),
	to_radians(col('pickup_latitude')).alias('pickup_lat_rads'))

taxi_temp2 = taxi_temp1.withColumn('pickup_Location', locateNYC(col('pickup_lat_rads'),col('pickup_long_rads'))).withColumn('pickup_day', dayofweek('pickup_datetime'))

taxi_temp3 = taxi_temp2.groupBy('pickup_location', 'pickup_day').count().sort('pickup_location','pickup_day')

taxi_temp3.show()

'''
#Need to forcefully convert back to Python floats, as Numpy floats cannot be processed in .toDF()
taxi_pickups = pickups.map(lambda trip: (trip[0], float(trip[1]), float(trip[2]), pickup_loc(float(trip[1]), float(trip[2]))))
#print taxi_pickups.take(5)

pickupDF = taxi_pickups.toDF(['vendorID','pickupLat','pickupLong','pickup_location'])
#pickupDF.show(50,False)
pickupDF.groupBy('pickup_location').count().sort('count').show()
'''


