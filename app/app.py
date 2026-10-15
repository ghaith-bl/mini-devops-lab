from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
REQUESTS = Counter("app_requests_total", "Total requests to home page")

@app.route("/")
def home():
    REQUESTS.inc()
    return "Hello from mini-devops-lab!\n"

@app.route("/health")
def health():
    return "ok\n"

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
