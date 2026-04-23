# hng14-stage2-devops

A job processing system with a FastAPI backend, Redis queue, background worker, and Express frontend.


## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Starting the Stack](#starting-the-stack)
- [Verifying a Successful Startup](#verifying-a-successful-startup)
- [Common Commands](#common-commands)
- [Stopping the Stack](#stopping-the-stack)

## Prerequisites

- Docker 24.0 or later
- Docker Compose v2.0 or later (`docker compose version` to check)
- GNU Make
- Git


## Environment Setup

Copy the example env files and fill in your values:

    cp .env.example api/.env
    cp .env.example worker/.env
    cp .env.example frontend/.env

Each service only reads the variables it needs. See `.env.example` for which
variables are required and what they do.

You should change the REDIS_PASSWORD placeholder before starting the program.


## Starting the Stack

    make up

This builds all images and starts all four services (redis, api, worker,
frontend) in detached mode. Services start in dependency order — Redis first,
then api and worker, then frontend. Each waits for its dependency to pass a
health check before starting.

The first run will take longer due to image pulls and builds. Subsequent runs
are faster.

## Verifying a Successful Startup

Check that all containers are running and healthy:

    make ps
    make health

Expected output from `make health`:

    Container health:
      /stack-redis-1       healthy
      /stack-api-1         healthy
      /stack-worker-1      healthy
      /stack-frontend-1    healthy

Check individual service health endpoints:

    curl <http://localhost:3000/healthz>

Open your browser and go to:

    http://localhost:3000

Click the `Submit` button and watch the status update from `queued` to `completed`.


## Common Commands

Start everything:
```
    make up
```

Start a single service:
```
    make up-service SERVICE=worker
```

View logs for all services:
```
    make logs
```

View logs for one service:
```
    make logs-service SERVICE=api
```

Open a shell in a container:
```
    make shell SERVICE=frontend
```

Rebuild one service after a code change:
```
    make build-service SERVICE=api
    make up-service SERVICE=api
```

Check container health:
```
    make health
```

## Stopping the Stack

Stop all containers but preserve data:

    make down

Stop and delete everything including Redis volume data:

    make nuke
