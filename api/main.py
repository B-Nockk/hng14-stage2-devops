import os
import uuid
from http import HTTPStatus

import redis
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException

load_dotenv()
app = FastAPI()


def require_env(key: str) -> str:
    value = os.getenv(key)
    if value is None:
        raise RuntimeError(f"Missing required environment variable: {key}")
    return value


REDIS_PASSWORD = require_env("REDIS_PASSWORD")
REDIS_HOST = require_env("REDIS_HOST")
REDIS_PORT = int(require_env("REDIS_PORT"))
SERVICE_PORT = int(require_env("SERVICE_PORT"))
SERVICE_HOST = require_env("SERVICE_HOST")

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PASSWORD)


@app.post("/jobs", status_code=201)
def create_job():
    job_id = str(uuid.uuid4())
    r.lpush("job", job_id)
    r.hset(f"job:{job_id}", "status", "queued")
    return {"job_id": job_id}


@app.get("/jobs/{job_id}")
def get_job(job_id: str):
    status = r.hget(f"job:{job_id}", "status")
    if not status:
        raise HTTPException(status_code=404, detail="Job not found")
    return {"job_id": job_id, "status": status.decode()}


@app.get("/healthz")
def health():
    return {
        "status": HTTPStatus.OK.value,
        "message": f"Service is healthy @ {SERVICE_PORT}",
    }


# Main entry point
if __name__ == "__main__":
    import uvicorn

    reload = os.getenv("RELOAD", "true").lower() == "true"

    uvicorn.run(
        "main:app",
        host=SERVICE_HOST,
        port=SERVICE_PORT,
        reload=reload,
        log_level="info",
        loop="uvloop",
        http="httptools",
    )
