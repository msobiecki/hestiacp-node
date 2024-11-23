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
fi
