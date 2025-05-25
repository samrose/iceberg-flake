import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

object SimpleIcebergApp {
  def main(args: Array[String]): Unit = {
    // Create Spark session with Iceberg configuration
    val spark = SparkSession.builder()
      .appName("Simple Iceberg App")
      .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions")
      .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog")
      .config("spark.sql.catalog.spark_catalog.type", "hadoop")
      .config("spark.sql.catalog.spark_catalog.warehouse", "spark-warehouse")
      .master("local[*]")
      .getOrCreate()

    try {
      // Create a simple DataFrame
      val data = Seq(
        (1, "Alice", 25),
        (2, "Bob", 30),
        (3, "Charlie", 35)
      )
      val df = spark.createDataFrame(data).toDF("id", "name", "age")

      // Create an Iceberg table
      df.writeTo("spark_catalog.default.users")
        .using("iceberg")
        .createOrReplace()

      // Read from the Iceberg table
      val readDf = spark.table("spark_catalog.default.users")
      
      println("=== Iceberg Table Contents ===")
      readDf.show()

      // Perform a simple query
      val filteredDf = readDf.filter(col("age") > 30)
      println("\n=== Filtered Results (age > 30) ===")
      filteredDf.show()

    } finally {
      spark.stop()
    }
  }
} 