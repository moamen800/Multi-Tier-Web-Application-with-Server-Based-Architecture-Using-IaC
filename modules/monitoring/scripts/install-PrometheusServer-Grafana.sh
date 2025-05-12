#!/bin/bash -e

# Prometheus Server Installation
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz
tar -xzf prometheus-2.35.0.linux-amd64.tar.gz

sudo useradd --no-create-home --shell /bin/false prometheus
sudo mv prometheus-2.35.0.linux-amd64/{prometheus,promtool} /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo mv prometheus-2.35.0.linux-amd64/{console*,prometheus.yml} /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

# Add Prometheus rules.yml
sudo tee /etc/prometheus/rules.yml > /dev/null <<EOF
---
groups:
  - name: Node_exporters
    rules:
      - record: Status_Nodes_Exporters
        expr: up{job="EC2_discover"}
        labels:
          node: "node_exporter"

      - alert: NodeDown
        expr: Status_Nodes_Exporters == 0
        for: 0s
        labels:
          node: "NodeDown"
        annotations:
          summary: "🚨 Node is down"
          description: "Node exporter is not responding."
          
  - name: CPU_Alerts
    rules:
      - alert: LowCpuLoad
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 20
        for: 1m
        labels:
          severity: low
          category: cpu
        annotations:
          summary: "🟢 Low CPU load on {{ index .Labels \"instance\" }}"
          description: |
            CPU load is above 20% for 1 minute on {{ index .Labels "instance" }}
            (current value: {{ printf "%.2f" .Value }}%).

      - alert: MediumCpuLoad
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 40
        for: 1m
        labels:
          severity: medium
          category: cpu
        annotations:
          summary: "🟡 Medium CPU load on {{ index .Labels \"instance\" }}"
          description: |
            CPU load is above 40% for 1 minute on {{ index .Labels "instance" }}
            (current value: {{ printf "%.2f" .Value }}%).

      - alert: HighCpuLoad
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 70
        for: 1m
        labels:
          severity: high
          category: cpu
        annotations:
          summary: "🔴 High CPU load on {{ index .Labels \"instance\" }}"
          description: |
            CPU load is above 70% for 1 minute on {{ index .Labels "instance" }}
            (current value: {{ printf "%.2f" .Value }}%).
EOF

sudo chown prometheus:prometheus /etc/prometheus/rules.yml

# Overwrite Prometheus Config
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
---
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: ["localhost:9093"]

rule_files:
  - "rules.yml"

scrape_configs:
  - job_name: "localhost_node_exporter"
    static_configs:
      - targets: ["localhost:9100"]

  - job_name: "EC2_discover"
    ec2_sd_configs:
      - region: "eu-west-1"
        port: 9100
        filters:
          - name: "tag:Title"
            values:
              - "prometheus"
EOF

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Prometheus Systemd Service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Start and Enable Prometheus
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

# Node Exporter Installation
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.3.1.linux-amd64.tar.gz
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Node Exporter Systemd Service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Start and Enable Node Exporter
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

# Alertmanager Installation
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
tar -xzf alertmanager-0.24.0.linux-amd64.tar.gz

sudo useradd --no-create-home --shell /bin/false alertmanager
sudo mv alertmanager-0.24.0.linux-amd64/{alertmanager,amtool} /usr/local/bin/
sudo chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}

sudo mkdir -p /etc/alertmanager
# Inside alertmanager.yml (edited)

sudo tee /etc/alertmanager/alertmanager.yml > /dev/null <<EOF
---
global:
  resolve_timeout: 15s

route:
  receiver: 'default'
  group_wait: 10s
  group_interval: 15s
  repeat_interval: 1h
  routes:
    - match:
        node: 'NodeDown'
      receiver: 'NodeDown'

    - match:
        severity: 'low'
        category: 'cpu'
      receiver: 'LowCpuSeverity'

    - match:
        severity: 'medium'
        category: 'cpu'
      receiver: 'MediumCpuSeverity'

    - match:
        severity: 'high'
        category: 'cpu'
      receiver: 'HighCpuSeverity'

receivers:
  - name: 'default'
    slack_configs:
      - channel: "#default"
        send_resolved: true
        api_url: '<SLACK_WEBHOOK_URL_DEFAULT>' # 🔒 Add your default Slack webhook URL here

  - name: 'NodeDown'
    slack_configs:
      - channel: "#nodedown-app"
        send_resolved: true
        api_url: '<SLACK_WEBHOOK_URL_NODEDOWN>' # 🔒 Add Slack webhook for NodeDown alerts here
    email_configs:
      - to: '<YOUR_EMAIL@example.com>'
        from: '<YOUR_EMAIL@example.com>'
        smarthost: smtp.gmail.com:587
        auth_username: '<YOUR_EMAIL@example.com>'
        auth_identity: '<YOUR_EMAIL@example.com>'
        auth_password: '<EMAIL_APP_PASSWORD>' # 🔒 Use an App Password, not your real password
        send_resolved: true

  - name: 'LowCpuSeverity'
    slack_configs:
      - channel: "#cpu-app"
        send_resolved: true
        api_url: '<SLACK_WEBHOOK_URL_CPU>' # 🔒 Add Slack webhook for low severity CPU alerts

  - name: 'MediumCpuSeverity'
    slack_configs:
      - channel: "#cpu-app"
        send_resolved: true
        api_url: '<SLACK_WEBHOOK_URL_CPU>' # 🔒 Reuse or update webhook as needed

  - name: 'HighCpuSeverity'
    slack_configs:
      - channel: "#cpu-app"
        send_resolved: true
        api_url: '<SLACK_WEBHOOK_URL_CPU>' # 🔒 Reuse or update webhook as needed
    email_configs:
      - to: '<YOUR_EMAIL@example.com>'
        from: '<YOUR_EMAIL@example.com>'
        smarthost: smtp.gmail.com:587
        auth_username: '<YOUR_EMAIL@example.com>'
        auth_identity: '<YOUR_EMAIL@example.com>'
        auth_password: '<EMAIL_APP_PASSWORD>' # 🔒 Use a Gmail App Password here
        send_resolved: true
EOF


sudo chown -R alertmanager:alertmanager /etc/alertmanager

# Alertmanager Systemd Service
sudo tee /etc/systemd/system/alertmanager.service > /dev/null <<EOF
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --web.external-url http://0.0.0.0:9093

[Install]
WantedBy=multi-user.target
EOF

# Start and Enable Alertmanager
sudo systemctl daemon-reload
sudo systemctl enable --now alertmanager

# Grafana Installation (from Official Repository)
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana

# Start and Enable Grafana
sudo systemctl enable --now grafana-server

# Final restarts to apply all configs
sudo systemctl restart prometheus.service
sudo systemctl restart alertmanager.service
sudo systemctl restart grafana-server.service

echo "------------------------------------------------------------"
echo "🎯 Monitoring stack setup completed successfully!"
echo ""
echo "✅  Prometheus downloaded, configured, and started as a service"
echo "✅  Prometheus rules (NodeDown, CPU alerts) created and applied"
echo "✅  Prometheus is scraping EC2 Node Exporters and localhost"
echo "✅  Node Exporter installed and exposed metrics at port 9100"
echo "✅  Alertmanager installed with Slack and email alert routes"
echo "✅  Systemd services for Prometheus, Node Exporter, and Alertmanager are running"
echo "✅  Grafana repository added and latest version installed"
echo "✅  Grafana server started and enabled to run on boot"
echo ""
echo "🚀 Your full Prometheus + Alertmanager + Grafana stack is live!"
echo "------------------------------------------------------------"

