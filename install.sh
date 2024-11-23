#!/bin/bash

# Check if NVM is already installed
if [[ -d "/opt/nvm" ]]
then
    echo "NVM is already installed."
else
    echo "Preinstalling NVM..."

    # Define the repository for NVM
    NVM_REPO="nvm-sh/nvm";

    # Fetch the latest version number of NVM
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/$NVM_REPO/releases/latest" \
        | grep "tag_name" \
        | cut -d '"' -f 4)

    if [[ -z "$LATEST_VERSION" ]]; then
        echo "Failed to retrieve the latest NVM version."
        exit 1
    fi

    echo "Installing NVM version $LATEST_VERSION..."

    # Download and run the NVM installation script
    wget -qO- "https://raw.githubusercontent.com/$NVM_REPO/$LATEST_VERSION/install.sh" | bash

    # Move NVM to the /opt directory for global access
    mv ~/.nvm /opt/nvm
    chmod -R 755 /opt/nvm
    
    # Set up environment variables for NVM
    export NVM_DIR="/opt/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Load NVM
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load NVM bash completion
    export PATH="/opt/nvm:$PATH"

    echo "NVM version $LATEST_VERSION successfully installed."

    # Install Node.js (latest LTS version)
    echo "Installing Node.js (latest LTS version)..."
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*

    echo "Node.js and npm installed successfully."

    # Install PM2 globally
    echo "Installing PM2 globally..."
    npm install -g pm2
    if [[ $? -eq 0 ]]; then
        echo "PM2 installed successfully."
    else
        echo "Failed to install PM2."
        exit 1
    fi
fi

# Synchronize template files
HESTIA_WEB_NGINX_TEMPLATE_SRC_DIR="./template/"
HESTIA_WEB_NGINX_TEMPLATE_DIR="/usr/local/hestia/data/templates/web/nginx/"
if [[ -d "$HESTIA_WEB_NGINX_TEMPLATE_SRC_DIR" ]]; then
    echo "Synchronizing template files to $HESTIA_WEB_NGINX_TEMPLATE_DIR..."
    rsync -r $HESTIA_WEB_NGINX_TEMPLATE_SRC_DIR $HESTIA_WEB_NGINX_TEMPLATE_DIR
    if [[ $? -eq 0 ]]; then
        echo "Template files synchronized successfully."
    else
        echo "Failed to synchronize template files."
        exit 1
    fi
else
    echo "Template directory '$HESTIA_WEB_NGINX_TEMPLATE_SRC_DIR' does not exist. Skipping synchronization."
fi

# Synchronize bin files
HESTIA_BIN_SRC_DIR="./bin"
HESTIA_BIN_DIR="/usr/local/hestia/bin"
if [[ -d "$HESTIA_BIN_SRC_DIR" ]]; then
    echo "Syncing files from $HESTIA_BIN_SRC_DIR to $HESTIA_BIN_DIR..."

    # Use rsync to copy all files from the source to the destination
    rsync -av --progress "$HESTIA_BIN_SRC_DIR/" "$HESTIA_BIN_DIR/"

    # Make all the copied files executable
    chmod +x "$HESTIA_BIN_DIR"/*

    echo "All files from $HESTIA_BIN_SRC_DIR copied and made executable successfully."
else
    echo "Source directory '$HESTIA_BIN_SRC_DIR' not found. Skipping this step."
fi

# Add start-all-pm2 to cron.d
CRON_SRC_DIR="./cron"
CRON_DIR="/etc/cron.d"
CRON_JOB_NAME="start-all-pm2"
if [[ -f "$CRON_SRC_DIR/$CRON_JOB_NAME" ]]; then
    echo "Copying $CRON_JOB_NAME script to $CRON_DIR..."
    cp "$CRON_SRC_DIR/$CRON_JOB_NAME" "$CRON_DIR/"
    
    # Ensure the cron file has the correct permissions
    chmod 644 "$CRON_DIR/$CRON_JOB_NAME"

    echo "$CRON_JOB_NAME copied to $CRON_DIR and permissions set."
else
    echo "$CRON_JOB_NAME script not found in '$CRON_SRC_DIR'. Skipping cron job setup."
fi

# Notify installation has finished
echo "Sending installation notification..."
/usr/local/hestia/bin/v-add-user-notification admin "Node application setup" "Node application setup has finished installing."

echo "Installation completed."
