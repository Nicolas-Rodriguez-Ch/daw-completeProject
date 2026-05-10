#!/bin/bash

# Build script for all microservices
# This script builds all Maven and Gradle projects to generate JAR files
# required for Docker image building

set -e  # Exit on error

echo "================================================"
echo "Building all microservices..."
echo "================================================"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Build Eureka service (Maven)
echo ""
echo ">>> Building eureka service..."
cd eureka
./mvnw clean package -DskipTests
cd ..

# Build API Gateway service (Maven)
echo ""
echo ">>> Building apigw service..."
cd apigw
./mvnw clean package -DskipTests
cd ..

# Build ms-operations service (Maven)
echo ""
echo ">>> Building ms-operations service..."
cd ms-operations
./mvnw clean package -DskipTests
cd ..

# Build ms-vehicles service (Gradle)
echo ""
echo ">>> Building ms-vehicles service..."
cd ms-vehicles
chmod +x gradlew
./gradlew build -x test
cd ..

echo ""
echo "================================================"
echo "✓ All services built successfully!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Run: docker-compose up --build"
echo "2. Access services at:"
echo "   - Eureka: http://localhost:8761"
echo "   - API Gateway: http://localhost:8762"
echo "   - ms-operations: http://localhost:8082"
echo "   - ms-vehicles: http://localhost:8088"
echo ""

