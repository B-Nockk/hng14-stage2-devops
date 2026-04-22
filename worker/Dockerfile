FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip==24.3.1 \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt


FROM python:3.12-slim AS runtime

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

COPY --from=builder /install /usr/local
COPY worker.py .

RUN mkdir -p /tmp && chown appuser /tmp

USER appuser

# No port to expose — worker is not a server

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD find /tmp/worker_health -mmin -2

CMD ["python", "worker.py"]
