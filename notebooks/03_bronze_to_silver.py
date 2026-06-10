# Databricks notebook source

# COMMAND ----------
# DBTITLE 1, Import encryption notebook
%run /Shared/02_pii_encryption

# COMMAND ----------
# DBTITLE 1, Config
catalog = "bdcc"
encryption_key = dbutils.secrets.get(scope="bdcc-scope", key="pii-encryption-key")
pii_columns = ["name", "address"]
bronze_table = f"{catalog}.bronze.hotel_weather_raw"
silver_table = f"{catalog}.silver.hotel_weather_processed"
checkpoint_path = f"/Volumes/{catalog}/silver/landing/_checkpoints/hotel_weather_processed"

# COMMAND ----------
# DBTITLE 1, Read stream from Bronze
df = (
    spark.readStream
    .format("delta")
    .table(bronze_table)
)

# COMMAND ----------
# DBTITLE 1, Decrypt PII in flight
encryptor = PIIEncryptor(encryption_key)
df_decrypted = encryptor.decrypt(df, pii_columns)

# COMMAND ----------
# DBTITLE 1, Apply transformations
from pyspark.sql.functions import trim, to_date, col, nullif, lit

df_transformed = (
    df_decrypted
    # Trim whitespace from string fields
    .withColumn("address", trim(col("address")))
    .withColumn("name", trim(col("name")))
    .withColumn("city", trim(col("city")))
    .withColumn("country", trim(col("country")))
    .withColumn("geoHash", trim(col("geoHash")))
    # Standardize date format
    .withColumn("wthr_date", to_date(col("wthr_date"), "yyyy-MM-dd"))
    # Cast year, month, day from string to int
    .withColumn("wthr_year", col("wthr_year").cast("int"))
    .withColumn("wthr_month", col("wthr_month").cast("int"))
    .withColumn("wthr_day", col("wthr_day").cast("int"))
    # Replace blank strings with null
    .withColumn("address", nullif(col("address"), lit("")))
    .withColumn("name", nullif(col("name"), lit("")))
    .withColumn("city", nullif(col("city"), lit("")))
    .withColumn("country", nullif(col("country"), lit("")))
    # Remove records with nulls in critical fields
    .filter(col("id").isNotNull() & col("wthr_date").isNotNull() & col("geoHash").isNotNull())
    # Remove duplicates
    .dropDuplicates(["id", "wthr_date"])
)

# COMMAND ----------
# DBTITLE 1, Re-encrypt PII before storing
df_final = encryptor.encrypt(df_transformed, pii_columns)

# COMMAND ----------
# DBTITLE 1, Write stream to Silver Delta table
query = (
    df_final.writeStream
    .format("delta")
    .outputMode("append")
    .trigger(availableNow=True)
    .option("checkpointLocation", checkpoint_path)
    .option("mergeSchema", "true")
    .toTable(silver_table)
)
