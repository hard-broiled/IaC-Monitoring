from flask import Flask, Response
from prometheus_client import Gauge, generate_latest, REGISTRY, start_http_server
import random
import time

app = Flask(__name__)

# Example metric
cpu_usage = Gauge("dummy_cpu_usage", "Simulated CPU usage")
memory_usage = Gauge("memory_usage_percent", "Simulated memory usage")


@app.route("/metrics")
def metrics():
    # Update metrics dynamically
    cpu_usage.set(random.randint(0, 100))
    memory_usage.set(random.randint(0, 100))
    return Response(generate_latest(REGISTRY), mimetype="text/plain")


if __name__ == "__main__":
    # app.run(host="0.0.0.0", port=8000) #old line
    # Expose metrics on port 8000
    start_http_server(8000)
    print("Python metrics service running on port 8000")
    while True:
        # Update metrics with random values
        cpu_usage.set(random.uniform(0, 100))
        memory_usage.set(random.uniform(0, 100))
        time.sleep(5)
