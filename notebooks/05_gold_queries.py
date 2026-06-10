# Databricks notebook source

# COMMAND ----------
# DBTITLE 1, Config
catalog = "bdcc"
gold_table = f"{catalog}.gold.hotel_weather_metrics"

# COMMAND ----------
# DBTITLE 1, Top 5 cities by number of distinct hotels
df_top5 = spark.sql(f"""
    SELECT city, country, SUM(distinct_hotels) as total_hotels
    FROM {gold_table}
    GROUP BY city, country
    ORDER BY total_hotels DESC
    LIMIT 5
""")

display(df_top5)

# COMMAND ----------
# DBTITLE 1, Dataset per city (use city name from top 5 above)
def get_city_dataset(city_name):
    return spark.sql(f"""
        SELECT
            wthr_date,
            distinct_hotels AS number_of_reported_hotels,
            avg_temperature AS avg_tmpr_c,
            max_temperature AS max_tmpr_c,
            min_temperature AS min_tmpr_c
        FROM {gold_table}
        WHERE city = '{city_name}'
        ORDER BY wthr_date
    """)

# COMMAND ----------
# DBTITLE 1, Preview - replace with actual top 5 city names after running the cell above
top5_cities = [row['city'] for row in df_top5.collect()]

for city in top5_cities:
    print(f"\n--- {city} ---")
    display(get_city_dataset(city))
