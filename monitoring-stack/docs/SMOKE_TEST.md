
# Monitoring Stack Smoke Test Checklist

Use this checklist after running `docker compose up --build` to verify that all core services are functional and connected.

---

## 1. Container Health

* [ ] Run `docker compose ps`

  * Confirm all containers are in **healthy** or **running** state.
  * Check logs for any crash loops:

    ```bash
    docker compose logs --tail=50 <service>
    ```

---

## 2. Prometheus

* [ ] Open Prometheus UI: [http://localhost:9090](http://localhost:9090)
* [ ] Query API to confirm targets:

  ```bash
  curl http://localhost:9090/api/v1/targets | jq .
  ```

  * At least **Prometheus itself** should show `"health": "up"`.
* [ ] Verify rules loaded:

  ```bash
  curl http://localhost:9090/api/v1/rules | jq .
  ```

---

## 3. Alertmanager

* [ ] Open Alertmanager UI: [http://localhost:9093](http://localhost:9093)
* [ ] Confirm it responds with a status JSON:

  ```bash
  curl http://localhost:9093/api/v2/status | jq .
  ```

* [ ] Verify Prometheus → Alertmanager wiring with a test alert:

  * In `prometheus/alert_rules.yml`, include:

    ```yaml
    - alert: TestAlwaysFiring
      expr: vector(1)
      for: 10s
      labels:
        severity: critical
      annotations:
        summary: "Test Alert"
        description: "This is a test alert that always fires."
    ```

  * Restart Prometheus and check:

    * Prometheus alerts page: [http://localhost:9090/alerts](http://localhost:9090/alerts)
    * Alertmanager UI: should show `TestAlwaysFiring`.

---

## 4. Grafana

* [ ] Open Grafana UI: [http://localhost:3000](http://localhost:3000)
* [ ] Log in (default: `admin` / `admin`, or configured creds).
* [ ] Navigate to **Connections → Data sources**:

  * Confirm Prometheus is present and shows **green “Data source is working”**.
* [ ] Import a test dashboard (or confirm your provisioning dashboards load).

---

## 5. Network + Persistence

* [ ] Run `docker network ls` → confirm all services share the same `monitoring-net` (or your chosen network).
* [ ] Verify volumes exist:

  ```bash
  docker volume ls | grep monitoring
  ```
* [ ] Restart stack with `docker compose down && docker compose up` and confirm dashboards + configs persist.

---

## 6. Cleanup (optional)

* [ ] Comment the `TestAlwaysFiring` alert rule after verifying wiring to avoid noise.
