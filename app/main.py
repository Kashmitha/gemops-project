"""
GemOps Flask API — instrumented with Prometheus metrics.
Python 3.11+ / Flask 3.1
"""

import os
import time
import logging
from flask import Flask, jsonify, request
from prometheus_client import (
    Counter, Histogram, generate_latest,
    CONTENT_TYPE_LATEST, CollectorRegistry, multiprocess
)
# Logging setup (Structured JSON for Loki)
logging.basicConfig(
    level=logging.INFO,
    format='{"time": "%(asctime)s", "level": "%(levelname)s", '
           '"message": "%(message)s", "module": "%(module)s"}'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Prometheus Metrics
REQUEST_COUNT = Counter(
    "gemops_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "gemops_request_duration_seconds",
    "Request latency in seconds",
    ["endpoint"],
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5]
)

ERROR_COUNT = Counter(
    "gemops_errors_total",
    "Total application errors",
    ["endpoint", "error_type"]
)

# Routes
@app.before_request
def start_timer():
    request.start_time = time.time()

@app.after_request
def record_metrics(response):
    latency = time.time() - request.start_time
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(endpoint=request.path).observe(latency)
    return response

@app.route("/")
def home():
    logger.info("Home endpoint called")
    return jsonify({
        "service": "gemops-api",
        "status": "healthy",
        "version": os.getenv("APP_VERSION", "1.0.0")
    })

@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/ready")
def ready():
    # Simulate readiness check (e.g., database connection)
    return jsonify({"status": "ready"}), 200

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

@app.route("/simulate-error")
def simulate_error():
    ERROR_COUNT.labels(endpoint="/simulate-error", error_type="test_error").inc()
    logger.error("Simulated error triggered")
    return jsonify({"error": "simulated error for alerting demo"}), 500

@app.route("/load")
def load():
    """Endpoint for load testing -- generates measurable latency."""
    time.sleep(0.1)
    return jsonify({"message": "load test response"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)