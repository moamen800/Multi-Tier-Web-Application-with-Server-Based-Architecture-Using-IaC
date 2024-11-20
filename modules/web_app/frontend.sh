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
git clone https://github.com/Kuzma02/Simple-MERN-App || { echo "Failed to clone repository"; exit 1; }
cd Simple-MERN-App || { echo "Failed to navigate to repository directory"; exit 1; }

# Step 4: Fetch the DNS name of the Application Load Balancer (ALB)
APP_ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names "app-servers-alb" \
    --query "LoadBalancers[0].DNSName" \
    --output text)

# Check if the DNS name was successfully retrieved
if [ -z "$APP_ALB_DNS" ]; then
  echo "Failed to retrieve ALB DNS. Exiting."
  exit 1
fi

echo "Replacing 'localhost' with the ALB DNS name ($APP_ALB_DNS)..."
find . -type f -exec sed -i "s/localhost/$APP_ALB_DNS/g" {} +

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
WEB_ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names "web-app-alb" \
    --query "LoadBalancers[0].DNSName" \
    --output text)

# Check if the DNS name was successfully retrieved
if [ -z "$WEB_ALB_DNS" ]; then
  echo "Failed to retrieve ALB DNS. Exiting."
  exit 1
fi

# Output the URL for testing the frontend deployment
echo "Frontend is accessible at http://$WEB_ALB_DNS"

