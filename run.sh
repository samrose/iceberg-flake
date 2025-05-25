#!/bin/bash

# Get the path to the Iceberg runtime JAR
ICEBERG_JAR=$(result/bin/iceberg-spark-runtime-classpath)

# Run the application with spark-submit
spark-submit \
  --class SimpleIcebergApp \
  --master local[*] \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.9.0 \
  --conf "spark.driver.extraJavaOptions=--add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED" \
  target/scala-2.12/simple-iceberg-app_2.12-0.1.0.jar 