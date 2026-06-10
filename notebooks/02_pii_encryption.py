# Databricks notebook source

# COMMAND ----------
# DBTITLE 1, Imports
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, aes_encrypt, aes_decrypt, base64, unbase64, lit

# COMMAND ----------
# DBTITLE 1, PIIEncryptor class
class PIIEncryptor:

    def __init__(self, encryption_key: str):
        self._key = lit(encryption_key)

    def encrypt(self, df: DataFrame, columns: list) -> DataFrame:
        for column in columns:
            df = df.withColumn(
                column,
                base64(aes_encrypt(col(column).cast("binary"), self._key, lit("GCM")))
            )
        return df

    def decrypt(self, df: DataFrame, columns: list) -> DataFrame:
        for column in columns:
            df = df.withColumn(
                column,
                aes_decrypt(unbase64(col(column)), self._key, lit("GCM")).cast("string")
            )
        return df
