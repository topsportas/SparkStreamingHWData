# Databricks notebook source

# COMMAND ----------
# DBTITLE 1, Import encryption notebook
%run /Shared/02_pii_encryption

# COMMAND ----------
# DBTITLE 1, Config
catalog = "bdcc"
encryption_key = dbutils.secrets.get(scope="bdcc-scope", key="pii-encryption-key")
pii_columns = ["name", "address"]
silver_table = f"{catalog}.silver.hotel_weather_processed"
gold_table = f"{catalog}.gold.hotel_weather_metrics"
checkpoint_path = f"/Volumes/{catalog}/gold/landing/_checkpoints/hotel_weather_metrics"

# COMMAND ----------
# DBTITLE 1, Read stream from Silver
df = (
    spark.readStream
    .format("delta")
    .table(silver_table)
)

# COMMAND ----------
# DBTITLE 1, Decrypt PII in flight
encryptor = PIIEncryptor(encryption_key)
df_decrypted = encryptor.decrypt(df, pii_columns)

# COMMAND ----------
# DBTITLE 1, Calculate metrics per country, city and date
from pyspark.sql.functions import approx_count_distinct, avg, max, min, round

df_gold = (
    df_decrypted
    .groupBy("country", "city", "wthr_date")
    .agg(
        approx_count_distinct("id").alias("distinct_hotels"),
        round(avg("avg_tmpr_c"), 2).alias("avg_temperature"),
        round(max("avg_tmpr_c"), 2).alias("max_temperature"),
        round(min("avg_tmpr_c"), 2).alias("min_temperature"),
        round(max("avg_tmpr_c") - min("avg_tmpr_c"), 2).alias("temperature_difference")
    )
)

# COMMAND ----------
# DBTITLE 1, Write stream to Gold Delta table
query = (
    df_gold.writeStream
    .format("delta")
    .outputMode("complete")
    .trigger(availableNow=True)
    .option("checkpointLocation", checkpoint_path)
    .toTable(gold_table)
)
