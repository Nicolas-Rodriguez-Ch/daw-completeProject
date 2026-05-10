# QUICKSTART Guide

## Get Started in 3 Steps

### Step 1: Build Services (5-10 minutes)

**Windows:**
```batch
build.bat
```

**Linux/Mac:**
```bash
./build.sh
```

**What happens:** All 4 microservices compile to JAR files in their target/build directories.

### Step 2: Start Docker Containers (30 seconds)

```bash
docker-compose up --build
```

**What happens:** 
- PostgreSQL database starts
- Eureka service registry starts
- All 4 microservices initialize and register with Eureka
- Services become ready to receive requests

### Step 3: Access Your Application

Open your browser and visit:

| What | URL |
|------|-----|
| **Eureka Dashboard** | http://localhost:8761 |
| **Vehicles API** | http://localhost:8088 |
| **Operations API** | http://localhost:8082 |
| **API Gateway** | http://localhost:8762 |

---

## Useful Commands

### Stop containers (keep data)
```bash
docker-compose stop
```

### Stop and remove containers (DELETE database data)
```bash
docker-compose down -v
```

### View logs
```bash
docker-compose logs -f ms-vehicles
```

### Check service status
```bash
docker-compose ps
```

---

## Common Issues

| Issue | Solution |
|-------|----------|
| "Port already in use" | Kill other process on that port or change port in docker-compose.yml |
| Services show "UNKNOWN" in Eureka | Wait 20-30 seconds and refresh |
| Can't connect to database | Wait for PostgreSQL to be healthy (check `docker-compose logs postgres`) |
| Build fails | Ensure Java 25+ installed: `java --version` |

---

## Full Documentation

See **README.md** for comprehensive documentation including:
- Environment variables
- API endpoints
- Troubleshooting guide
- Architecture diagrams
- Development workflow

---

**Ready to go!** If it's your first time, follow the README.md "Quick Start" section for more details.

