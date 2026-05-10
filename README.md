# Microservices Architecture - Docker Compose Setup

## Project Overview

This project implements a microservices architecture with the following components:

- **Eureka**: Service registry and discovery server (Port: 8761)
- **API Gateway**: Spring Cloud Gateway for routing requests (Port: 8762)
- **ms-operations**: Operations microservice (Port: 8082)
- **ms-vehicles**: Vehicles microservice with PostgreSQL database (Port: 8088)
- **PostgreSQL**: Database for vehicles service (Port: 5432)

## Prerequisites

Before running this project, ensure you have the following installed:

### Required Software

- **Docker**: Version 20.10 or higher
  - Download: https://www.docker.com/products/docker-desktop
  
- **Docker Compose**: Version 1.29 or higher
  - Usually included with Docker Desktop
  - Verify: `docker-compose --version`

- **Git** (optional, for cloning the repository)

### Hardware Requirements

- Minimum 4GB RAM available for Docker
- At least 10GB free disk space for Docker images and volumes
- Multi-core processor recommended

## Quick Start

### Step 1: Build All Services

Run the build script to compile all Maven and Gradle projects:

**On Linux/Mac:**
```bash
chmod +x build.sh
./build.sh
```

**On Windows (Command Prompt or PowerShell):**
```batch
build.bat
```

This script will:
- Build the Eureka service (Maven)
- Build the API Gateway service (Maven)
- Build the ms-operations service (Maven)
- Build the ms-vehicles service (Gradle)

**Expected output:** All services should display "BUILD SUCCESS" at the end.

### Step 2: Start All Services with Docker Compose

Navigate to the project root directory (where `docker-compose.yml` is located) and run:

```bash
docker-compose up --build
```

**Flags explanation:**
- `--build`: Rebuilds Docker images before starting containers (optional if already built)
- `-d`: Run in detached mode (add this flag to run in background)

**Expected output:**
```
Creating network "entregable_microservices-network" with driver "bridge"
Creating vehicles-db ... done
Creating eureka-server ... done
Creating ms-vehicles ... done
Creating ms-operations ... done
Creating apigw ... done
```

### Step 3: Verify Services Are Running

Check if all containers are running:

```bash
docker-compose ps
```

Expected output:
```
CONTAINER ID   IMAGE                   COMMAND                  STATUS       PORTS
...            entregable-postgres     "docker-entrypoint..."   Up (healthy) 5432/tcp
...            eureka-server           "java -jar /app.jar"     Up           8761/tcp
...            ms-vehicles             "java -jar /app.jar"     Up           8088/tcp
...            ms-operations           "java -jar /app.jar"     Up           8082/tcp
...            apigw                   "java -jar /app.jar"     Up           8762/tcp
```

## Service Endpoints

Once all services are running, access them at:

| Service | URL | Purpose |
|---------|-----|---------|
| Eureka | http://localhost:8761 | Service Discovery Dashboard |
| API Gateway | http://localhost:8762 | Main entry point for all requests |
| ms-operations | http://localhost:8082 | Operations service (direct access) |
| ms-vehicles | http://localhost:8088 | Vehicles service (direct access) |
| PostgreSQL | localhost:5432 | Database for vehicles |

### API Gateway Routes

The API Gateway routes requests to microservices:

- `/ms-operations/**` → Routes to ms-operations service (port 8082)
- `/ms-vehicles/**` → Routes to ms-vehicles service (port 8088)

**Example requests:**
```bash
# Through API Gateway
curl http://localhost:8762/ms-vehicles/api/vehicles

# Direct to service
curl http://localhost:8088/api/vehicles
```

### Swagger Documentation

Access API documentation at:

- **ms-vehicles**: http://localhost:8088/swagger-ui.html
- **ms-operations**: http://localhost:8082/swagger-ui.html

## Common Docker Compose Commands

### Start services in background
```bash
docker-compose up -d
```

### View logs from all services
```bash
docker-compose logs -f
```

### View logs from specific service
```bash
docker-compose logs -f ms-vehicles
```

### Stop all services
```bash
docker-compose stop
```

### Stop and remove containers (keeps volumes)
```bash
docker-compose down
```

### Remove containers and volumes (WARNING: deletes database data)
```bash
docker-compose down -v
```

### Rebuild and restart services
```bash
docker-compose up -d --build
```

### Restart a specific service
```bash
docker-compose restart ms-vehicles
```

## Database Connection

### PostgreSQL Details

- **Host**: `localhost` (or `postgres` from within Docker network)
- **Port**: `5432`
- **Database**: `vehicles_db`
- **Username**: `user`
- **Password**: `password`

### Connect with psql (if installed locally)

```bash
psql -h localhost -p 5432 -U user -d vehicles_db
```

### Using pgAdmin (optional)

You can add pgAdmin to the docker-compose.yml for GUI database management:

```yaml
pgadmin:
  image: dpage/pgadmin4
  environment:
    PGADMIN_DEFAULT_EMAIL: admin@admin.com
    PGADMIN_DEFAULT_PASSWORD: admin
  ports:
    - "5050:80"
  depends_on:
    - postgres
  networks:
    - microservices-network
```

Then add to docker-compose.yml and access at http://localhost:5050

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Network                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              API Gateway (Port 8762)                 │  │
│  │  - Routes /ms-operations/** → ms-operations         │  │
│  │  - Routes /ms-vehicles/** → ms-vehicles             │  │
│  └───────────────────┬──────────────────────────────────┘  │
│                      │                                      │
│          ┌───────────┴───────────┐                         │
│          │                       │                         │
│  ┌───────▼──────────┐   ┌────────▼────────────┐           │
│  │  ms-operations   │   │   ms-vehicles       │           │
│  │  (Port 8082)     │   │   (Port 8088)       │           │
│  │                  │   │                     │           │
│  │ Eureka Client    │   │ Eureka Client       │           │
│  │                  │   │ + Database Client   │           │
│  └──────────────────┘   └────────┬────────────┘           │
│                                  │                         │
│  ┌──────────────────────────┐    │                        │
│  │    Eureka Server         │    │                        │
│  │    (Port 8761)           │    │                        │
│  │    - Service Registry    │    │                        │
│  │    - Discovery           │    │                        │
│  └──────────────────────────┘    │                        │
│                                  │                        │
│                          ┌────────▼────────────┐          │
│                          │   PostgreSQL       │          │
│                          │   (Port 5432)      │          │
│                          │   vehicles_db      │          │
│                          └────────────────────┘          │
│                                                           │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Services fail to start

**Problem**: Containers exit immediately
- **Solution**: Check logs with `docker-compose logs <service-name>`
- **Common cause**: Ports already in use

### Port already in use

**Problem**: Error like "Bind for 0.0.0.0:8761 failed: port is already allocated"
- **Solution 1**: Stop other services using that port
- **Solution 2**: Change port mapping in docker-compose.yml (first part of `ports:` under each service)

### Services can't communicate

**Problem**: Services can't reach each other
- **Solution**: Ensure all services are on the same network (check `docker-compose ps`)
- **Verify**: Services should use container names (e.g., `http://eureka:8761`) not localhost

### Database connection errors

**Problem**: ms-vehicles can't connect to PostgreSQL
- **Verify**:
  1. PostgreSQL container is running: `docker-compose ps postgres`
  2. Database initialized: `docker-compose logs postgres | tail -20`
  3. Wait longer for database to be healthy (takes ~30 seconds on first start)

### Eureka showing "Unknown"

**Problem**: Services appear in Eureka but show "UNKNOWN" status
- **Cause**: Services haven't registered yet (wait a few seconds)
- **Solution**: Refresh Eureka dashboard after 15-30 seconds

### High memory usage

**Problem**: Docker containers consuming too much RAM
- **Solution**: Reduce JVM heap in Dockerfiles:
  - Add to ENTRYPOINT: `-Xmx512m -Xms256m`

### Slow startup

**Problem**: Services take more than 2 minutes to start
- **Cause**: This is normal for first startup with dependency downloads
- **Future starts**: Much faster (images cached)

## Build Troubleshooting

### Maven build fails

**Problem**: `mvn` command not found or build fails
- **Solution**: Ensure Java 25+ is installed
- **Verify**: In each service directory, run `./mvn --version`

### Gradle build fails

**Problem**: Gradle build fails in ms-vehicles
- **Solution**: 
  1. Ensure Java 25+ is installed
  2. Run in ms-vehicles: `chmod +x gradlew`
  3. Try: `./gradlew clean build -x test`

### Clean rebuild needed

```bash
# Remove all Docker images and volumes
docker-compose down -v

# Rebuild everything
./build.sh        # Linux/Mac
# or
build.bat         # Windows

# Start fresh
docker-compose up --build
```

## Environment Variables

Services receive environment variables from docker-compose.yml:

### ms-vehicles
- `SPRING_DATASOURCE_URL`: PostgreSQL connection string
- `SPRING_DATASOURCE_USERNAME`: Database user
- `SPRING_DATASOURCE_PASSWORD`: Database password
- `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE`: Eureka server URL

### ms-operations
- `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE`: Eureka server URL

### apigw
- `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE`: Eureka server URL

To modify these, edit `docker-compose.yml` under each service's `environment:` section.

## Advanced Configuration

### Change database credentials

Edit `docker-compose.yml`:

```yaml
postgres:
  environment:
    POSTGRES_DB: vehicles_db
    POSTGRES_USER: your_user      # Change this
    POSTGRES_PASSWORD: your_pass  # Change this
    
ms-vehicles:
  environment:
    SPRING_DATASOURCE_USERNAME: your_user      # Match above
    SPRING_DATASOURCE_PASSWORD: your_pass      # Match above
```

### Change service ports

Edit `docker-compose.yml` and modify the `ports:` section:

```yaml
ms-vehicles:
  ports:
    - "9088:8088"  # Map 9088 on host to 8088 in container
```

### Add additional services

To add a new microservice:

1. Add service block to `docker-compose.yml`
2. Add dependency on eureka
3. Set `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE` environment variable
4. Add to network configuration

## Development Workflow

### During development

1. **Without Docker** (local development):
   - Start PostgreSQL: `docker-compose up postgres -d`
   - Run services from IDE/IDE with Spring Boot configuration

2. **With Docker** (testing full setup):
   - Build services: `./build.sh`
   - Start all: `docker-compose up --build`

### Making code changes

1. Modify code in your IDE
2. Rebuild service: `mvn clean package` (in Maven projects) or `./gradlew build` (in Gradle project)
3. Restart container: `docker-compose up --build <service-name>`

### Debugging

View service logs in real-time:

```bash
docker-compose logs -f ms-vehicles

# Follow logs from multiple services
docker-compose logs -f ms-vehicles ms-operations
```

## Support and Documentation

### Useful Links

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Spring Boot in Docker](https://spring.io/guides/gs/spring-boot-docker/)
- [Eureka Documentation](https://github.com/Netflix/eureka/wiki)
- [Spring Cloud Gateway](https://spring.io/projects/spring-cloud-gateway)

### Project Structure

```
entregable/
├── build.sh                    # Linux/Mac build script
├── build.bat                   # Windows build script
├── docker-compose.yml          # Docker Compose configuration
├── README.md                   # This file
├── eureka/                     # Eureka service
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/
├── apigw/                      # API Gateway service
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/
├── ms-operations/              # Operations service
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/
└── ms-vehicles/                # Vehicles service
    ├── build.gradle
    ├── Dockerfile
    └── src/
```

## License

This project is part of the Especialización en Desarrollo de Aplicaciones Web program.

---

**Last Updated**: 2026-05-10
**Version**: 1.0

