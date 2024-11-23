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
TEMPLATE_DIR="/usr/local/hestia/data/templates/web/nginx/"
if [[ -d "${TEMPLATE_DIR}" ]]; then
    echo "Removing synchronized template files..."
    find "${TEMPLATE_DIR}" -type f -exec rm -f {} +
    echo "Template files removed from ${TEMPLATE_DIR}."
else
    echo "Template directory does not exist. Skipping template file removal."
fi

# Notify uninstallation has finished
echo "Sending uninstallation notification..."
/usr/local/hestia/bin/v-add-user-notification admin "Node application setup" "Node application setup has been uninstalled."

echo "Uninstallation completed."
