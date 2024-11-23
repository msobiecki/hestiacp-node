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
echo "Synchronizing template files..."
if [[ -d "./template/" ]]; then
    rsync -r ./template/ /usr/local/hestia/data/templates/web/nginx/
    if [[ $? -eq 0 ]]; then
        echo "Template files synchronized successfully."
    else
        echo "Failed to synchronize template files."
        exit 1
    fi
else
    echo "Template directory './template/' does not exist. Skipping synchronization."
fi

# Copy the v-start-pm2 script to bin directory
echo "Copying v-start-pm2..."
if [[ -f "./bin/v-start-pm2" ]]; then
    cp "./bin/v-start-pm2" "/usr/local/hestia/bin/"
    chmod +x "/usr/local/hestia/bin/v-start-pm2"
    echo "v-start-pm2 copied and made executable successfully."
else
    echo "v-start-pm2 script not found at './bin/'. Skipping this step."
fi

# Notify installation has finished
echo "Sending installation notification..."
/usr/local/hestia/bin/v-add-user-notification admin "Node application setup" "Node application setup has finished installing."

echo "Installation completed."
