"""
Tests for GemOps Flask API
"""
import pytest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_health_returns_ok(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "ok"

def test_ready_returns_ready(client):
    response = client.get("/ready")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "ready"

def test_home_returns_service_info(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["service"] == "gemops-api"
    assert "version" in data

def test_simulate_error_returns_500(client):
    response = client.get("/simulate-error")
    assert response.status_code == 500
    data = response.get_json()
    assert "error" in data

def test_metrics_endpoint_returns_prometheus_format(client):
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"gemops" in response.data

def test_load_endpoint_returns_200(client):
    response = client.get("/load")
    assert response.status_code == 200
