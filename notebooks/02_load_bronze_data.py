# Databricks notebook source

# COMMAND ----------
# DBTITLE 1, Import encryption notebook
%run /Shared/02_pii_encryption

# COMMAND ----------
# DBTITLE 1, Config
catalog = "bdcc"
source_path = f"/Volumes/{catalog}/bronze/landing/m13sparkstreaming/hotel-weather/"
checkpoint_path = f"/Volumes/{catalog}/bronze/landing/_checkpoints/hotel_weather_raw"
schema_path = f"/Volumes/{catalog}/bronze/landing/_schema/hotel_weather_raw"
bronze_table = f"{catalog}.bronze.hotel_weather_raw"
encryption_key = dbutils.secrets.get(scope="bdcc-scope", key="pii-encryption-key")
pii_columns = ["name", "address"]

# COMMAND ----------
# DBTITLE 1, Schema
from pyspark.sql.types import StructType, StructField, StringType, DoubleType

schema = StructType([
    StructField("address", StringType()),
    StructField("avg_tmpr_c", DoubleType()),
    StructField("avg_tmpr_f", DoubleType()),
    StructField("city", StringType()),
    StructField("country", StringType()),
    StructField("geoHash", StringType()),
    StructField("id", StringType()),
    StructField("latitude", DoubleType()),
    StructField("longitude", DoubleType()),
    StructField("name", StringType()),
    StructField("wthr_date", StringType()),
    StructField("wthr_year", StringType()),
    StructField("wthr_month", StringType()),
    StructField("wthr_day", StringType()),
])

# COMMAND ----------
# DBTITLE 1, Read stream with Auto Loader
df = (
    spark.readStream
    .format("cloudFiles")
    .option("cloudFiles.format", "parquet")
    .option("cloudFiles.schemaLocation", schema_path)
    .schema(schema)
    .load(source_path)
)

# COMMAND ----------
# DBTITLE 1, Encrypt PII before storing
encryptor = PIIEncryptor(encryption_key)
df_encrypted = encryptor.encrypt(df, pii_columns)

# COMMAND ----------
# DBTITLE 1, Write stream to Bronze Delta table
query = (
    df_encrypted.writeStream
    .format("delta")
    .outputMode("append")
    .trigger(availableNow=True)
    .option("checkpointLocation", checkpoint_path)
    .option("mergeSchema", "true")
    .toTable(bronze_table)
)
