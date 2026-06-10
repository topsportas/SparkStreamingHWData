# Databricks notebook source
# DBTITLE 1,Cell 1
dbutils.widgets.text("catalog", "bdcc", "Catalog name")
catalog = dbutils.widgets.get("catalog")

spark.sql(f"CREATE CATALOG IF NOT EXISTS `{catalog}`")

spark.sql(f"""
    CREATE SCHEMA IF NOT EXISTS `{catalog}`.bronze
    COMMENT 'Bronze layer: raw ingested data'
""")

spark.sql(f"""
    CREATE SCHEMA IF NOT EXISTS `{catalog}`.silver
    COMMENT 'Silver layer: cleaned and deduplicated data'
""")

spark.sql(f"""
    CREATE SCHEMA IF NOT EXISTS `{catalog}`.gold
    COMMENT 'Gold layer: aggregated and business-ready data'
""")

spark.sql(f"CREATE VOLUME IF NOT EXISTS `{catalog}`.bronze.landing COMMENT 'Raw source files'")
spark.sql(f"CREATE VOLUME IF NOT EXISTS `{catalog}`.silver.landing COMMENT 'Silver layer checkpoints'")
spark.sql(f"CREATE VOLUME IF NOT EXISTS `{catalog}`.gold.landing COMMENT 'Gold layer checkpoints'")

display(spark.sql(f"SHOW SCHEMAS IN `{catalog}`"))