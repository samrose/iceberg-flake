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

4. Run the application:
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

## Dependencies

- Apache Spark 3.5.0
- Apache Iceberg 1.9.0
- Scala 2.12.18

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 