#!/bin/bash

# Step 1: Clone the repository
echo "Cloning the Simple-MERN-App repository..."
git clone https://github.com/Kuzma02/Simple-MERN-App || { echo "Failed to clone repository"; exit 1; }
cd Simple-MERN-App || { echo "Failed to navigate to repository directory"; exit 1; }

# Step 2: Update package lists and install npm
echo "Updating package list and installing npm..."
sudo apt-get update -y
sudo apt-get install -y npm || { echo "Failed to install npm"; exit 1; }

# Step 3: Install Node.js if not installed
echo "Checking for Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing..."
    sudo apt-get install -y nodejs || { echo "Failed to install Node.js"; exit 1; }
else
    echo "Node.js is already installed."
fi

# Step 4: Install pm2 globally if not already installed
echo "Checking for pm2 installation..."
if ! command -v pm2 &> /dev/null; then
    echo "pm2 not found. Installing..."
    sudo npm install -g pm2 || { echo "Failed to install pm2"; exit 1; }
else
    echo "pm2 is already installed."
fi

# Step 5: Create and configure .env file
echo "Configuring the .env file..."
touch .env
echo "MONGO_URI=mongodb+srv://Moamen:123@cluster0.qf7fpar.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0" > .env
echo "PORT=3000" >> .env
echo ".env file configured successfully."

# Step 6: Install app dependencies
echo "Installing app dependencies..."
npm install || { echo "Failed to install app dependencies"; exit 1; }
npm audit fix

# Step 7: Start the app using pm2
echo "Starting the app using pm2..."
pm2 start app.js --name Simple-MERN-App || { echo "Failed to start the app with pm2"; exit 1; }
pm2 save
pm2 startup || { echo "Failed to configure pm2 for startup"; exit 1; }

# Verify if the app started successfully
sleep 5
if pm2 list | grep -q "Simple-MERN-App"; then
    echo "Backend application started successfully with pm2."
else
    echo "Failed to start the backend application with pm2."
    exit 1
fi
