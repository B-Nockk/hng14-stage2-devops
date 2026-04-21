import os
import signal
import time

import redis
from dotenv import load_dotenv

load_dotenv()

REDIS_PASSWORD = os.getenv("REDIS_PASSWORD")
REDIS_HOST = os.getenv("REDIS_HOST")
REDIS_PORT = int(os.getenv("REDIS_PORT"))
r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PASSWORD)


def process_job(job_id):
    print(f"Processing job {job_id}")
    time.sleep(2)  # simulate work
    r.hset(f"job:{job_id}", "status", "completed")
    print(f"Done: {job_id}")


def handle_signal(sig, frame):
    print("Shutting down worker...")
    exit(0)


signal.signal(signal.SIGTERM, handle_signal)
signal.signal(signal.SIGINT, handle_signal)

while True:
    try:
        job = r.brpop("job", timeout=5)
        if job:
            _, job_id = job
            process_job(job_id.decode())
    except Exception as e:
        print(f"Redis error: {e}")
        time.sleep(2)
    finally:
        with open("/tmp/worker_health", "w") as f:
            f.write(str(time.time()))
