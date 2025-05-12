#!/bin/bash

# Step 1: Update package lists and install required tools
echo "Updating package list..."
sudo apt-get update -y || { echo "Failed to update package list"; exit 1; }

echo "Installing required tools (curl, unzip, git, wget)..."
sudo apt-get install -y curl unzip git wget || { echo "Failed to install required tools"; exit 1; }

# Step 2: Install AWS CLI if not already installed
echo "Checking for AWS CLI installation..."
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || { echo "Failed to download AWS CLI"; exit 1; }
    unzip awscliv2.zip || { echo "Failed to unzip AWS CLI package"; exit 1; }
    sudo ./aws/install || { echo "Failed to install AWS CLI"; exit 1; }
    echo "AWS CLI installed successfully."
else
    echo "AWS CLI is already installed."
fi

# Step 3: Clone the repository
echo "Cloning the Simple-MERN-App repository..."
cd /home/ubuntu || { echo "Failed to change to /home/ubuntu directory"; exit 1; }
git clone https://github.com/Kuzma02/Simple-MERN-App || { echo "Failed to clone repository"; exit 1; }
cd Simple-MERN-App || { echo "Failed to navigate to repository directory"; exit 1; }

# Step 4: Install npm
echo "Installing npm..."
sudo apt-get install -y npm || { echo "Failed to install npm"; exit 1; }

# Step 5: Install Node.js if not already installed
echo "Checking for Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs || { echo "Failed to install Node.js"; exit 1; }
else
    echo "Node.js is already installed."
fi

# Step 6: Install pm2 globally if not already installed
echo "Checking for pm2 installation..."
if ! command -v pm2 &> /dev/null; then
    echo "pm2 not found. Installing pm2..."
    sudo npm install -g pm2 || { echo "Failed to install pm2"; exit 1; }
else
    echo "pm2 is already installed."
fi

# Step 7: Download DocumentDB CA certificate
echo "Downloading Amazon DocumentDB Certificate Authority (CA) certificate..."
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem || { echo "Failed to download DocumentDB CA certificate"; exit 1; }

# Step 8: Configure .env file
echo "Configuring the .env file..."
echo "Fetching DocumentDB Cluster endpoint..."
DB_ENDPOINT=$(aws docdb describe-db-clusters --db-cluster-identifier "mydatabase14121414" --query "DBClusters[0].Endpoint" --output text)

if [ "$DB_ENDPOINT" == "None" ] || [ -z "$DB_ENDPOINT" ]; then
    echo "Failed to retrieve DocumentDB cluster endpoint. Please verify your cluster name and AWS credentials."
    exit 1
fi

echo "DocumentDB Cluster endpoint: $DB_ENDPOINT"

# Create the .env file
touch .env
echo "MONGO_URI=mongodb://Moamen:moamen146@$DB_ENDPOINT:27017/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false" > .env
echo "PORT=3000" >> .env
echo ".env file configured successfully."

# Step 9: Install app dependencies
echo "Installing app dependencies..."
npm install || { echo "Failed to install app dependencies"; exit 1; }
npm audit fix || { echo "npm audit fix failed"; exit 1; }
npm install cors

# Step 10: Start the app using pm2
echo "Starting the app using pm2..."
pm2 start app.js --name Simple-MERN-App || { echo "Failed to start the app with pm2"; exit 1; }
pm2 save
pm2 startup systemd || { echo "Failed to configure pm2 for startup"; exit 1; }

# Step 11: Verify if the app started successfully
if pm2 list | grep -q "Simple-MERN-App"; then
    echo "Backend application started successfully with pm2."
else
    echo "Failed to start the backend application with pm2."
    exit 1
fi

# Step 12: Install Node Exporter
echo "Installing Node Exporter..."
cd ~
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz || { echo "Failed to download Node Exporter"; exit 1; }
tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz || { echo "Failed to extract Node Exporter"; exit 1; }

# Create a dedicated user for Node Exporter
sudo useradd --no-create-home --shell /bin/false node_exporter

# Move the Node Exporter binary
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


# Final summary
echo "------------------------------------------------------------"
echo "🎯 Setup completed successfully!"
echo ""
echo "✅  System packages updated and tools installed (curl, unzip, git, wget, npm)"
echo "✅  AWS CLI installed and verified"
echo "✅  Simple-MERN-App cloned and configured"
echo "✅  Node.js and pm2 installed and set up"
echo "✅  DocumentDB connection configured (.env file created)"
echo "✅  App dependencies installed"
echo "✅  Backend application started and managed by pm2"
echo "✅  Node Exporter installed and running for monitoring"
echo ""
echo "🚀 Your Simple-MERN-App backend is now running and ready!"
echo "------------------------------------------------------------"