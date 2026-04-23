<!-- markdownlint-disable MD024 -->
# Bug Fixes

All bugs found and fixed across the starter files.

## Table of Contents

## Table of Contents

- [api/main.py](#apimainpy)
- [api/requirements.txt](#apirequirementstxt)
- [worker/worker.py](#workerworkerpy)
- [frontend](#frontend)

---

## api/main.py

### Hardcoded configuration

- All required env values (host, port, Redis connection) were hardcoded literals.

- **Fixed By** loading from environment variables via python-dotenv.

### Missing Uvicorn Startup Entry Point

- **Fixed By**: integrating a `uvicorn.run` block to provide a direct entry point.

### Redis password not used

- `.env` defined `REDIS_PASSWORD` but the Redis client was constructed without it, meaning the connection would be rejected by a password-protected Redis instance.

- **Fixed By:** `redis.Redis(..., password=REDIS_PASSWORD)`

### POST /jobs returned 200

- Creating a resource should return 201 Created.
- **Fixed By:** `@app.post("/jobs", status_code=201)`

### Missing 404 on unknown job

- `get_job` returned `{"error": "not found"}` with an implicit 200 status.

- **Fixed By:** `raise HTTPException(status_code=404, detail="Job not found")`

### No health endpoint

Added `GET /healthz` returning status 200 for Docker and load balancer checks.

---

## api/requirements.txt

### Problem reading env vars

- **Fixed By:**
  - added `python-dotenv==1.0.0` to requirements.txt
  - loaded env vars with `load_dotenv()`

### Environment Variables Not Loading

- Application was unable to read values from the environment configuration.
- **Fixed By:**
  - adding `python-dotenv==1.0.0` to `requirements.txt`
  - loading variables explicitly with `load_dotenv()`

### Unpinned Core Dependencies

- Unversioned packages may introduce breaking changes in future installs or deployments.
- **Fixed By:**
  - pinning minimum known stable versions using `>=` constraints
  - switching to `uvicorn[standard]` to include performance and protocol extras

---

## worker/worker.py

### Environment Variables Not Loading

- Application was unable to read values from the environment configuration.
- **Fixed By:**
  - adding `python-dotenv==1.0.0` to `requirements.txt`
  - loading variables explicitly with `load_dotenv()`

### Redis password not used

- `.env` defined `REDIS_PASSWORD` but the Redis client was constructed without it, meaning the connection would be rejected by a password-protected Redis instance.

- **Fixed By:** `redis.Redis(..., password=REDIS_PASSWORD)`

### signal imported but never used

`import signal` was present with no signal handlers registered,
meaning the worker could not shut down cleanly on SIGTERM from Docker.
Fixed: added `handle_signal()` and registered it for SIGTERM and SIGINT.

### No health mechanism

Docker had no way to verify the worker was alive.
Fixed: worker writes current timestamp to `/tmp/worker_health` on every loop
iteration. Docker healthcheck verifies the file is not older than 2 minutes.

## frontend

### Redis password not used

Same pattern as backend services.
Fixed: added `REDIS_PASSWORD` to env loading (consumed by api, not frontend
directly, but noted for consistency).

### Upstream error status codes swallowed

Both proxy routes caught errors and always returned 500, hiding the real
status code from the API (e.g. 404 for unknown job).
Fixed: `res.status(err.response?.status || 500).json(...)`

### Port hardcoded

`app.listen(3000, ...)` ignored environment configuration.
Fixed: `app.listen(parseInt(require_env("SERVICE_PORT")), ...)`

### No health endpoint

Added `GET /healthz` for Docker healthcheck.
