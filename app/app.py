import signal
import sys

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

def handle_sigterm(signum, frame):
    # Called when the container gets SIGTERM (podman stop / Kubernetes)
    # Exit cleanly with code 0 instead of waiting to be killed
    sys.exit(0)

if __name__ == "__main__":
    # Python running as PID 1 ignores SIGTERM unless a handler is registered
    signal.signal(signal.SIGTERM, handle_sigterm)
    app.run(host="0.0.0.0", port=5000)
