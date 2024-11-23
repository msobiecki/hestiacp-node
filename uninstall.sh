#!/bin/bash

echo "Starting the uninstallation process..."

# Uninstall NVM and Node.js
if [[ -d "/opt/nvm" ]]; then
    echo "Removing NVM and Node.js..."
    rm -rf /opt/nvm
    sed -i '/export NVM_DIR=\/opt\/nvm/d' ~/.bashrc ~/.zshrc
    sed -i '/\[ -s "\$NVM_DIR\/nvm.sh" \] && \. "\$NVM_DIR\/nvm.sh"/d' ~/.bashrc ~/.zshrc
    sed -i '/\[ -s "\$NVM_DIR\/bash_completion" \] && \. "\$NVM_DIR\/bash_completion"/d' ~/.bashrc ~/.zshrc
    sed -i '/export PATH="\/opt\/nvm:\$PATH"/d' ~/.bashrc ~/.zshrc
    echo "NVM and Node.js removed."
else
    echo "NVM is not installed. Skipping NVM removal."
fi

# Uninstall PM2
if command -v pm2 >/dev/null 2>&1; then
    echo "Removing PM2..."
    npm uninstall -g pm2
    if [[ $? -eq 0 ]]; then
        echo "PM2 removed successfully."
    else
        echo "Failed to remove PM2."
    fi
else
    echo "PM2 is not installed. Skipping PM2 removal."
fi

# Remove synchronized template files
HESTIA_WEB_NGINX_TEMPLATE_DIR="/usr/local/hestia/data/templates/web/nginx/"
if [[ -d "$HESTIA_WEB_NGINX_TEMPLATE_DIR" ]]; then
    echo "Removing synchronized template files from $HESTIA_WEB_NGINX_TEMPLATE_DIR..."
    find "$HESTIA_WEB_NGINX_TEMPLATE_DIR" -type f -exec rm -f {} +
    echo "Template files removed."
else
    echo "Template directory does not exist. Skipping template file removal."
fi

# Remove the v-start-pm2 script from bin directory
HESTIA_BIN_DIR="/usr/local/hestia/bin"
HESTIA_PM2_SCRIPT_NAME="v-start-pm2"
if [[ -f "$HESTIA_BIN_DIR/$HESTIA_PM2_SCRIPT_NAME" ]]; then
    echo "Removing $HESTIA_PM2_SCRIPT_NAME from $HESTIA_BIN_DIR..."
    rm -f "$HESTIA_BIN_DIR/$HESTIA_PM2_SCRIPT_NAME"
    echo "$HESTIA_PM2_SCRIPT_NAME removed."
else
    echo "$HESTIA_PM2_SCRIPT_NAME not found in $HESTIA_BIN_DIR. Skipping this step."
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

# Notify uninstallation has finished
echo "Sending uninstallation notification..."
/usr/local/hestia/bin/v-add-user-notification admin "Node application setup" "Node application setup has been uninstalled."

echo "Uninstallation completed."
