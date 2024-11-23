#!/bin/bash

# Check if NVM is already installed
if [[ -d "/opt/nvm" ]]
then
    echo "NVM is already installed."
else
    echo "Preinstalling NVM..."

    # Define the repository for NVM
    nvm_string="nvm-sh/nvm";

    # Function to fetch the latest release version from GitHub
    git_latest_version() {
        curl -fsSL -o /dev/null -w "%{redirect_url}" "https://github.com/$1/releases/latest" | xargs basename
    }

    # Fetch the latest version number of NVM
    LATEST_VERSION=$(git_latest_version "${NVM_REPO}")

    if [[ -z "$LATEST_VERSION" ]]; then
        echo "Failed to retrieve the latest NVM version."
        exit 1
    fi

    echo "Installing NVM version ${LATEST_VERSION}..."

    # Download and run the NVM installation script
    wget -qO- "https://raw.githubusercontent.com/${NVM_REPO}/${LATEST_VERSION}/install.sh" | bash

    # Move NVM to the /opt directory for global access
    mv ~/.nvm /opt/nvm
    chmod -R 755 /opt/nvm
    
    # Set up environment variables for NVM
    export NVM_DIR="/opt/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Load NVM
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load NVM bash completion
    export PATH="/opt/nvm:$PATH"

    echo "NVM version ${LATEST_VERSION} successfully installed."

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

# Copy the v-start-pm2 script to bin directory
HESTIA_BIN_SRC_DIR="./bin"
HESTIA_BIN_DIR="/usr/local/hestia/bin"
HESTIA_PM2_SCRIPT_NAME="v-start-pm2"
if [[ -f "$HESTIA_BIN_SRC_DIR/$HESTIA_PM2_SCRIPT_NAME" ]]; then
    echo "Copying $HESTIA_PM2_SCRIPT_NAME to $HESTIA_BIN_DIR..."
    rsync -av --progress "$HESTIA_BIN_SRC_DIR/$HESTIA_PM2_SCRIPT_NAME" "$HESTIA_BIN_DIR/"
    chmod +x "$HESTIA_BIN_DIR/$HESTIA_PM2_SCRIPT_NAME"
    echo "$HESTIA_PM2_SCRIPT_NAME copied and made executable successfully."
else
    echo "$HESTIA_PM2_SCRIPT_NAME script not found at '$HESTIA_BIN_SRC_DIR'. Skipping this step."
fi

# Notify installation has finished
echo "Sending installation notification..."
/usr/local/hestia/bin/v-add-user-notification admin "Node application setup" "Node application setup has finished installing."

echo "Installation completed."
