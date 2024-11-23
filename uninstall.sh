#!/bin/bash

echo "Starting the uninstallation process..."

# Uninstall NVM and Node.js
if [[ -d "/opt/nvm" ]]; then
    echo "Removing NVM and Node.js..."
    rm -rf /opt/nvm

    # Remove NVM-related lines from /etc/profile
    sudo sed -i "/export NVM_DIR='\/opt\/nvm'/d" /etc/profile
    sudo sed -i "/\[ -s '\$NVM_DIR\/nvm.sh' \] && \. '\$NVM_DIR\/nvm.sh'/d" /etc/profile
    sudo sed -i "/\[ -s '\$NVM_DIR\/bash_completion' \] && \. '\$NVM_DIR\/bash_completion'/d" /etc/profile
    sudo sed -i "/export PATH='\/opt\/nvm:\$PATH'/d" /etc/profile
    
    # Remove NVM-related lines from /root/.profile
    sudo sed -i "/export NVM_DIR='\/root\/.nvm'/d" /root/.profile
    sudo sed -i "/\[ -s '\$NVM_DIR\/nvm.sh' \] && \. '\$NVM_DIR\/nvm.sh'/d" /root/.profile
    sudo sed -i "/\[ -s '\$NVM_DIR\/bash_completion' \] && \. '\$NVM_DIR\/bash_completion'/d" /root/.profile
    sudo sed -i "/export PATH='\/root\/.nvm:\$PATH'/d" /root/.profile

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

# Remove synchronized bin files
HESTIA_BIN_DIR="/usr/local/hestia/bin"
HESTIA_BIN_SRC_DIR="./bin"
if [[ -d "$HESTIA_BIN_SRC_DIR" ]]; then
    echo "Removing files from $HESTIA_BIN_DIR..."

    # Loop through all files in the source directory
    for file in "$HESTIA_BIN_SRC_DIR"/*; do
        script_name=$(basename "$file")
        
        # If the file exists in the target directory, remove it
        if [[ -f "$HESTIA_BIN_DIR/$script_name" ]]; then
            echo "Removing $script_name from $HESTIA_BIN_DIR..."
            rm -f "$HESTIA_BIN_DIR/$script_name"
            echo "$script_name removed."
        else
            echo "$script_name not found in $HESTIA_BIN_DIR. Skipping removal."
        fi
    done
else
    echo "Source directory '$HESTIA_BIN_SRC_DIR' not found. Skipping file removal."
fi

# Remove the start-all-pm2 cron job
CRON_DIR="/etc/cron.d"
CRON_JOB_NAME="start-all-pm2"
if [[ -f "$CRON_DIR/$CRON_JOB_NAME" ]]; then
    echo "Removing $CRON_JOB_NAME from $CRON_DIR..."
    rm -f "$CRON_DIR/$CRON_JOB_NAME"
    echo "$CRON_JOB_NAME removed from cron jobs."
else
    echo "$CRON_JOB_NAME not found in $CRON_DIR. Skipping cron removal."
fi

# Notify uninstallation has finished
echo "Sending uninstallation notification..."
/usr/local/hestia/bin/v-add-user-notification admin "Node application setup" "Node application setup has been uninstalled."

echo "Uninstallation completed."
