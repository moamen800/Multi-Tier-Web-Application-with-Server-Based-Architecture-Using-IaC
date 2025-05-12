#!/bin/bash

# Step 1: Update package lists and install required tools
echo "Updating package list..."
sudo apt-get update -y || { echo "Failed to update package list"; exit 1; }

echo "Installing required tools (curl, unzip)..."
sudo apt-get install -y curl unzip || { echo "Failed to install required tools"; exit 1; }

# Step 2: Install AWS CLI if not already installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || { echo "Failed to download AWS CLI"; exit 1; }
    unzip awscliv2.zip || { echo "Failed to unzip AWS CLI package"; exit 1; }
    sudo ./aws/install || { echo "Failed to install AWS CLI"; exit 1; }
    echo "AWS CLI installed successfully."
else
    echo "AWS CLI is already installed."
fi

# Step 3: Clone the MERN application repository
echo "Cloning the Simple-MERN-App repository..."
cd /home/ubuntu || { echo "Failed to navigate to home directory"; exit 1; }
git clone https://github.com/Kuzma02/Simple-MERN-App || { echo "Failed to clone repository"; exit 1; }
cd Simple-MERN-App || { echo "Failed to navigate to repository directory"; exit 1; }

# Step 4: Fetch the DNS name of the Application Load Balancer (ALB)
Business_logic_ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names "business-logic-alb" \
    --query "LoadBalancers[0].DNSName" \
    --output text)

# Check if the DNS name was successfully retrieved
if [ -z "$Business_logic_ALB_DNS" ]; then
  echo "Failed to retrieve ALB DNS. Exiting."
  exit 1
fi

echo "Replacing 'localhost' with the ALB DNS name ($Business_logic_ALB_DNS)..."
find . -type f -exec sed -i "s/localhost/$Business_logic_ALB_DNS/g" {} +

npm install cors

# Step 5: Install client dependencies
echo "Installing client-side dependencies..."
cd client || { echo "Failed to navigate to client directory"; exit 1; }

echo "Updating package lists and installing npm..."
sudo apt-get install -y npm || { echo "Failed to install npm"; exit 1; }

echo "Installing Node.js dependencies..."
npm install || { echo "Failed to install Node.js dependencies"; exit 1; }
npm audit fix

# Step 6: Install and start the Apache server
cd ..
echo "Installing and starting Apache server..."
sudo apt-get install -y apache2 || { echo "Failed to install Apache"; exit 1; }
sudo systemctl enable apache2
sudo systemctl start apache2

# Step 7: Build the frontend
cd client || { echo "Failed to navigate to client directory"; exit 1; }
echo "Building the frontend..."
npm run build || { echo "Failed to build frontend"; exit 1; }

# Step 8: Deploy frontend files to Apache's web directory
echo "Deploying frontend to Apache server..."
sudo cp -r dist/* /var/www/html/ || { echo "Failed to deploy frontend files"; exit 1; }

# Step 9: Output the URL for testing the deployment
# Fetch the DNS name of the internet-facing Application Load Balancer (ALB)
Presentation_ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names "presentation-alb" \
    --query "LoadBalancers[0].DNSName" \
    --output text)

# Check if the DNS name was successfully retrieved
if [ -z "$Presentation_ALB_DNS" ]; then
  echo "Failed to retrieve ALB DNS. Exiting."
  exit 1
fi

# Output the URL for testing the frontend deployment
echo "Frontend is accessible at http://$Presentation_ALB_DNS"

# Step 10: Install Node Exporter
echo "Installing Node Exporter..."
cd ~
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz || { echo "Failed to download Node Exporter"; exit 1; }
tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz || { echo "Failed to extract Node Exporter"; exit 1; }

sudo useradd --no-create-home --shell /bin/false node_exporter
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create Node Exporter service file
echo "Creating Node Exporter service..."
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

# Start and enable Node Exporter
echo "Starting Node Exporter service..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Final detailed summary
echo "------------------------------------------------------------"
echo "🎯 Setup completed successfully!"
echo ""
echo "✅  System packages updated and tools installed (curl, unzip, npm, apache2)"
echo "✅  AWS CLI installed and verified"
echo "✅  Simple-MERN-App cloned from GitHub and configured"
echo "✅  Backend API reconfigured to point to ALB DNS: $Business_logic_ALB_DNS"
echo "✅  Frontend built and deployed via Apache2"
echo "✅  Frontend accessible at: http://$Presentation_ALB_DNS"
echo "✅  Node Exporter installed and running for monitoring"
echo ""
echo "🚀 Your MERN application is now fully deployed and live!"
echo "------------------------------------------------------------"