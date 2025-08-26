from flask import Flask, Response
from prometheus_client import Gauge, generate_latest, REGISTRY
import random
import time

app = Flask(__name__)

# Example metric
cpu_gauge = Gauge("dummy_cpu_usage", "Simulated CPU usage")

@app.route("/metrics")
def metrics():
    # Update metrics dynamically
    cpu_gauge.set(random.randint(0, 100))
    return Response(generate_latest(REGISTRY), mimetype="text/plain")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
