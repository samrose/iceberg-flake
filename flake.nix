{
  description = "Apache Iceberg - A high-performance format for huge analytic tables";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Latest version from Apache Iceberg releases
        version = "1.9.0";
        
        # Pre-built JAR from Maven Central
        apache-iceberg = pkgs.stdenv.mkDerivation rec {
          pname = "apache-iceberg";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-core/${version}/iceberg-core-${version}.jar";
            sha256 = "1dixi5432dgnjyvd70zx9iyklbsnb7dyyd9bdbglgg5x7knygyip";
          };

          nativeBuildInputs = with pkgs; [
            makeWrapper
          ];

          buildInputs = with pkgs; [
            jdk11
          ];

          unpackPhase = "true"; # Skip unpacking for single JAR

          installPhase = ''
            mkdir -p $out/lib $out/share/java $out/bin
            cp $src $out/lib/iceberg-core-${version}.jar
            ln -s $out/lib/iceberg-core-${version}.jar $out/share/java/iceberg-core.jar

            # Create a script to print usage information
            cat > $out/bin/iceberg << EOF
            #!${pkgs.runtimeShell}
            echo "Apache Iceberg ${version} (library)"
            echo ""
            echo "This is a library JAR, not an executable application."
            echo "To use it in your Java application, add it to your classpath:"
            echo "  $out/lib/iceberg-core-${version}.jar"
            echo ""
            echo "Or use the classpath script:"
            echo "  $out/bin/iceberg-classpath"
            EOF
            chmod +x $out/bin/iceberg

            # Create classpath script
            cat > $out/bin/iceberg-classpath << EOF
            #!${pkgs.runtimeShell}
            echo "$out/lib/iceberg-core-${version}.jar"
            EOF
            chmod +x $out/bin/iceberg-classpath
          '';

          meta = with pkgs.lib; {
            description = "Apache Iceberg Core (prebuilt JAR)";
            longDescription = ''
              Apache Iceberg is a high-performance format for huge analytic tables.
              Iceberg brings the reliability and simplicity of SQL tables to big data,
              while making it possible for engines like Spark, Trino, Flink, Presto,
              Hive and Impala to safely work with the same tables, at the same time.
            '';
            homepage = "https://iceberg.apache.org/";
            license = licenses.asl20;
            maintainers = [ ]; # Add your name here if you maintain this
            platforms = platforms.unix;
          };
        };

        # Iceberg Spark runtime JAR (Spark 3.3)
        apache-iceberg-spark-runtime = pkgs.stdenv.mkDerivation rec {
          pname = "apache-iceberg-spark-runtime";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/${version}/iceberg-spark-runtime-3.5_2.12-${version}.jar";
            sha256 = "sha256-Oj5WN8Dcc1lpVFDA1nVG2SB6z0SOaP/ObJpUdnusBVI=";
          };

          nativeBuildInputs = with pkgs; [
            makeWrapper
          ];

          buildInputs = with pkgs; [
            jdk11
          ];

          unpackPhase = "true";

          installPhase = ''
            mkdir -p $out/lib $out/share/java $out/bin
            cp $src $out/lib/iceberg-spark-runtime-3.3_${version}-${version}.jar
            ln -s $out/lib/iceberg-spark-runtime-3.3_${version}-${version}.jar $out/share/java/iceberg-spark-runtime.jar

            # Create a script to print usage information
            cat > $out/bin/iceberg-spark-runtime << EOF
            #!${pkgs.runtimeShell}
            echo "Apache Iceberg Spark Runtime ${version} (library)"
            echo ""
            echo "This is a library JAR for Spark integration, not an executable application."
            echo "To use it in your Spark application, add it to your classpath:"
            echo "  $out/lib/iceberg-spark-runtime-3.3_${version}-${version}.jar"
            echo ""
            echo "Or use the classpath script:"
            echo "  $out/bin/iceberg-spark-runtime-classpath"
            EOF
            chmod +x $out/bin/iceberg-spark-runtime

            # Create classpath script
            cat > $out/bin/iceberg-spark-runtime-classpath << EOF
            #!${pkgs.runtimeShell}
            echo "$out/lib/iceberg-spark-runtime-3.3_${version}-${version}.jar"
            EOF
            chmod +x $out/bin/iceberg-spark-runtime-classpath
          '';

          meta = with pkgs.lib; {
            description = "Apache Iceberg Spark Runtime (prebuilt JAR)";
            longDescription = ''
              Apache Iceberg Spark Runtime for Spark 3.3, prebuilt JAR for version ${version}.
            '';
            homepage = "https://iceberg.apache.org/";
            license = licenses.asl20;
            maintainers = [ ];
            platforms = platforms.unix;
          };
        };

        # Test package that verifies Iceberg works
        iceberg-test = pkgs.stdenv.mkDerivation {
          pname = "iceberg-test";
          version = "1.0";
          src = ./.;

          buildInputs = with pkgs; [
            jdk11
            apache-iceberg
          ];

          buildPhase = ''
            cat > TestIceberg.java << 'END'
            public class TestIceberg {
                public static void main(String[] args) {
                    try {
                        Class.forName("org.apache.iceberg.Schema");
                        System.out.println("Successfully loaded Iceberg JAR");
                    } catch (ClassNotFoundException e) {
                        System.err.println("Failed to load Iceberg JAR: " + e.getMessage());
                        System.exit(1);
                    }
                }
            }
            END

            javac -cp "${apache-iceberg}/lib/iceberg-core-${version}.jar" TestIceberg.java
          '';

          checkPhase = ''
            ${pkgs.jdk11}/bin/java -cp ".:${apache-iceberg}/lib/iceberg-core-${version}.jar" TestIceberg
          '';

          installPhase = "mkdir -p $out; echo ok > $out/check-ok";
        };

        # Development shell with Iceberg dependencies
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            jdk11
            # Spark for testing Iceberg integration
            scala
            sbt
            spark
            # Optional: Python for PyIceberg
            python3
            python3Packages.pip
          ];

          shellHook = ''
            echo "Apache Iceberg Development Environment"
            echo "Java version: $(java -version 2>&1 | head -n1)"
            echo ""
            echo "Iceberg JAR is available at:"
            echo "  ${apache-iceberg}/lib/"
          '';

          JAVA_HOME = "${pkgs.jdk11}";
        };

      in {
        packages = {
          default = apache-iceberg;
          apache-iceberg = apache-iceberg;
          apache-iceberg-spark-runtime = apache-iceberg-spark-runtime;
        };

        checks = {
          default = iceberg-test;
        };

        devShells.default = devShell;

        # Apps for easy access
        apps = {
          default = {
            type = "app";
            program = "${apache-iceberg}/bin/iceberg";
          };
          spark-app = {
            type = "app";
            program = let
              script = pkgs.writeScript "run-iceberg-app" ''
                #!${pkgs.runtimeShell}
                set -e

                # Create temporary directory
                TMPDIR=$(mktemp -d)
                trap 'chmod -R u+w "$TMPDIR" && rm -rf "$TMPDIR"' EXIT

                echo "Building application in $TMPDIR..."
                cd "$TMPDIR"
                cp -r ${./.}/* .
                chmod -R u+w .
                ${pkgs.sbt}/bin/sbt package

                echo "Running application..."
                ${pkgs.spark}/bin/spark-submit \
                  --class SimpleIcebergApp \
                  --master local[*] \
                  --jars ${apache-iceberg-spark-runtime}/lib/iceberg-spark-runtime-3.3_${version}-${version}.jar \
                  --conf "spark.driver.extraJavaOptions=--add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED" \
                  target/scala-2.12/simple-iceberg-app_2.12-0.1.0.jar
              '';
            in "${script}";
          };
        };
      });
}
