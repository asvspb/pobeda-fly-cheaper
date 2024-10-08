#!/bin/bash

# Check for Python
if ! command -v python3 &> /dev/null
then
    echo "Python is not installed. Please install Python 3.10 or higher and try again."
    exit 1
else
    echo "Python is already installed."
fi

# Check for Git
if ! command -v git &> /dev/null
then
    echo "Git is not installed. Installing Git..."
    sudo apt-get update
    sudo apt-get install -y git
    echo "Git has been successfully installed."
else
    echo "Git is already installed."
fi

TODO
# Clone repository
REPO_URL="https://github.com/your-username/ticket-search-app.git"
PROJECT_FOLDER="ticket-search-app"

if [ ! -d "$PROJECT_FOLDER" ]; then
    echo "Cloning repository..."
    git clone $REPO_URL $PROJECT_FOLDER
else
    echo "Project folder already exists. Skipping cloning."
fi

# Change to project folder
cd $PROJECT_FOLDER

# Create and activate virtual environment
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Install Chrome and ChromeDriver
echo "Installing Chrome and ChromeDriver..."
sudo apt-get update
sudo apt-get install -y wget unzip

# Install Chrome
if ! command -v google-chrome &> /dev/null
then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt-get install -f
    rm google-chrome-stable_current_amd64.deb
fi

# Install ChromeDriver
CHROME_DRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)
wget -N https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/
unzip ~/chromedriver_linux64.zip -d ~/
rm ~/chromedriver_linux64.zip
sudo mv -f ~/chromedriver /usr/local/bin/chromedriver
sudo chown root:root /usr/local/bin/chromedriver
sudo chmod 0755 /usr/local/bin/chromedriver

# Start server
echo "Starting server..."
python3 app.py
