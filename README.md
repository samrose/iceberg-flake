# Apache Iceberg Spark Dev Env

This project demonstrates how to use Apache Iceberg with Apache Spark, packaged as a Nix flake. It includes a simple example application that creates an Iceberg table, inserts data, and performs basic queries.

## Prerequisites

- [Nix](https://nixos.org/download.html) installed on your system
- Basic understanding of Apache Spark and Apache Iceberg

## Project Structure

```
.
├── flake.nix           # Nix flake definition
├── build.sbt          # SBT build configuration
├── run.sh             # Script to run the application
└── src/
    └── main/
        └── scala/
            └── SimpleIcebergApp.scala  # Example application
```

## Getting Started

1. Enter the development shell:
```bash
nix develop
```

2. Compile the application:
```bash
sbt compile
```

3. Package the application:
```bash
sbt package
```

4. Run the application (choose one method):

   a. Using the Nix flake app (recommended):
   ```bash
   nix run .#spark-app
   ```
   This will:
   - Create a temporary directory
   - Build the application
   - Run it
   - Clean up automatically

   b. Using the run script:
   ```bash
   ./run.sh
   ```

## What the Example Does

The example application:
1. Creates a Spark session with Iceberg configuration
2. Creates a simple DataFrame with sample data
3. Writes the data to an Iceberg table
4. Reads the data back
5. Performs a simple filter operation

## Data Storage

The Iceberg tables are stored in the `spark-warehouse` directory in your project folder. This is configured to use a local Hadoop catalog for simplicity.

### Verifying Data Storage

1. After running the application, you'll find the data in:
   ```
   spark-warehouse/
   └── default/
       └── users/
           ├── data/           # Contains the actual data files
           ├── metadata/       # Contains Iceberg metadata
           └── snapshots/      # Contains table snapshots
   ```

2. The data persists between runs. You can verify this by:
   - Running the application once
   - Looking in the `spark-warehouse` directory
   - Running the application again - it will show the same data

3. The table is created with the name `spark_catalog.default.users` and uses Iceberg's format for storage.

## Dependencies

- Apache Spark 3.5.0
- Apache Iceberg 1.9.0
- Scala 2.12.18

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 