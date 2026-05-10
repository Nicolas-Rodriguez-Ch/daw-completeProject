@echo off
REM Build script for all microservices (Windows)
REM This script builds all Maven and Gradle projects to generate JAR files
REM required for Docker image building

setlocal enabledelayedexpansion
set SCRIPT_DIR=%~dp0

echo.
echo ================================================
echo Building all microservices...
echo ================================================
echo.

REM Build Eureka service (Maven)
echo >>> Building eureka service...
cd /d "%SCRIPT_DIR%eureka"
call mvnw clean package -DskipTests
if errorlevel 1 (
    echo Error building eureka
    exit /b 1
)
cd /d "%SCRIPT_DIR%"

REM Build API Gateway service (Maven)
echo.
echo >>> Building apigw service...
cd /d "%SCRIPT_DIR%apigw"
call mvnw clean package -DskipTests
if errorlevel 1 (
    echo Error building apigw
    exit /b 1
)
cd /d "%SCRIPT_DIR%"

REM Build ms-operations service (Maven)
echo.
echo >>> Building ms-operations service...
cd /d "%SCRIPT_DIR%ms-operations"
call mvnw clean package -DskipTests
if errorlevel 1 (
    echo Error building ms-operations
    exit /b 1
)
cd /d "%SCRIPT_DIR%"

REM Build ms-vehicles service (Gradle)
echo.
echo >>> Building ms-vehicles service...
cd /d "%SCRIPT_DIR%ms-vehicles"
call gradlew build -x test
if errorlevel 1 (
    echo Error building ms-vehicles
    exit /b 1
)
cd /d "%SCRIPT_DIR%"

echo.
echo ================================================
echo X All services built successfully!
echo ================================================
echo.
echo Next steps:
echo 1. Run: docker-compose up --build
echo 2. Access services at:
echo    - Eureka: http://localhost:8761
echo    - API Gateway: http://localhost:8762
echo    - ms-operations: http://localhost:8082
echo    - ms-vehicles: http://localhost:8088
echo.

endlocal

