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

# Prometheus Systemd Service
sudo tee /etc/systemd/system/prometheus.service <<EOF
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
sudo tee /etc/systemd/system/node_exporter.service <<EOF
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
sudo mv alertmanager-0.24.0.linux-amd64/alertmanager.yml /etc/alertmanager/
sudo chown -R alertmanager:alertmanager /etc/alertmanager

# Alertmanager Systemd Service
sudo tee /etc/systemd/system/alertmanager.service <<EOF
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

# Import GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add Grafana repository
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Update package list and install Grafana
sudo apt-get update
sudo apt-get install -y grafana

# Start and Enable Grafana
sudo systemctl enable --now grafana-server

echo "✅ Prometheus, Node Exporter, Alertmanager, and Grafana have been installed and started."
