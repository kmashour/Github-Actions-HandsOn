import pytest
import time
from app import app as flask_app

@pytest.fixture
def client():
    with flask_app.test_client() as client:
        yield client

def test_integration_flow(client):
    # Simulates hitting external endpoints or performing DB connection validations
    time.sleep(1)  # Simulates network latency
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert "version" in data
    assert data["version"] == "1.0.0"
