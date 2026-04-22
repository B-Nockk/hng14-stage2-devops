FROM python:3.12-alpine AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip==24.3.1 \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt


FROM python:3.12-alpine AS runtime

# Non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local

COPY main.py .

# Switch to non-root
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", \
    "--log-level", "info"]
