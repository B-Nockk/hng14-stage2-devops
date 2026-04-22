from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

# Patch redis before importing the app so the module-level
# redis.Redis() call never touches a real connection
with patch("redis.Redis") as mock_redis_cls:
    mock_redis_cls.return_value = MagicMock()
    from api.main import app

client = TestClient(app)


@pytest.fixture(autouse=True)
def mock_redis():
    with patch("main.r") as mock_r:
        yield mock_r


def test_create_job_returns_201_and_job_id(mock_redis):
    response = client.post("/jobs")
    assert response.status_code == 201
    data = response.json()
    assert "job_id" in data
    assert len(data["job_id"]) == 36  # UUID format


def test_create_job_queues_in_redis(mock_redis):
    response = client.post("/jobs")
    job_id = response.json()["job_id"]
    mock_redis.lpush.assert_called_once_with("job", job_id)
    mock_redis.hset.assert_called_once_with(f"job:{job_id}", "status", "queued")


def test_get_job_returns_status(mock_redis):
    mock_redis.hget.return_value = b"queued"
    response = client.get("/jobs/test-job-123")
    assert response.status_code == 200
    assert response.json() == {"job_id": "test-job-123", "status": "queued"}


def test_get_job_returns_404_when_not_found(mock_redis):
    mock_redis.hget.return_value = None
    response = client.get("/jobs/nonexistent")
    assert response.status_code == 404


def test_healthz_returns_200(mock_redis):
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json()["status"] == 200
