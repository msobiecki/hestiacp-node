#!/bin/bash

echo "Starting the uninstallation process..."

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

# Uninstall NVM and Node.js
if [[ -d "/opt/nvm" ]]; then
    echo "Removing NVM directory..."
    sudo rm -rf /opt/nvm
    echo "NVM directory removed."
else
    echo "NVM directory not found. Skipping removal."
fi

# Remove NVM-related lines from /etc/profile
echo "Removing NVM configuration from /etc/profile..."
sudo sed -i '/export NVM_DIR="\/opt\/nvm"/d' /etc/profile
sudo sed -i '/\[ -s "\$NVM_DIR\/nvm.sh" \] && \. "\$NVM_DIR\/nvm.sh"/d' /etc/profile
sudo sed -i '/\[ -s "\$NVM_DIR\/bash_completion" \] && \. "\$NVM_DIR\/bash_completion"/d' /etc/profile
sudo sed -i '/export PATH="\/opt\/nvm:\$PATH"/d' /etc/profile
echo "NVM configuration removed from /etc/profile."

# Remove NVM-related lines from /root/.profile
echo "Removing NVM configuration from /root/.profile..."
sudo sed -i '/export NVM_DIR="\/opt\/nvm"/d' /root/.profile
sudo sed -i '/\[ -s "\$NVM_DIR\/nvm.sh" \] && \. "\$NVM_DIR\/nvm.sh"/d' /root/.profile
sudo sed -i '/\[ -s "\$NVM_DIR\/bash_completion" \] && \. "\$NVM_DIR\/bash_completion"/d' /root/.profile
sudo sed -i '/export PATH="\/opt\/nvm:\$PATH"/d' /root/.profile
echo "NVM configuration removed from /root/.profile."

# Reload environment variables
echo "Reloading environment variables..."
source /etc/profile
if [[ $(whoami) == "root" ]]; then
    source /root/.profile
fi


echo "NVM uninstallation completed."

# Remove synchronized template files
HESTIA_WEB_NGINX_TEMPLATE_DIR="/usr/local/hestia/data/templates/web/nginx/"
HESTIA_WEB_NGINX_TEMPLATE_SRC_DIR="./templates"
if [[ -d "$HESTIA_WEB_NGINX_TEMPLATE_DIR" && -d "$HESTIA_WEB_NGINX_TEMPLATE_SRC_DIR" ]]; then
    echo "Removing matching template files from $HESTIA_WEB_NGINX_TEMPLATE_DIR based on names in $HESTIA_WEB_NGINX_TEMPLATE_SRC_DIR..."

    # Loop through each file in the source template directory
    for template_file in "$HESTIA_WEB_NGINX_TEMPLATE_SRC_DIR"/*; do
        template_name=$(basename "$template_file")
        target_file="$HESTIA_WEB_NGINX_TEMPLATE_DIR/$template_name"
        
        # If the file exists in the target directory, remove it
        if [[ -f "$target_file" ]]; then
            echo "Removing $target_file..."
            rm -f "$target_file"
        else
            echo "$template_name does not exist in $HESTIA_WEB_NGINX_TEMPLATE_DIR. Skipping."
        fi
    done

    echo "Matching template files removed."
else
    echo "One or both directories do not exist. Skipping template file removal."
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
