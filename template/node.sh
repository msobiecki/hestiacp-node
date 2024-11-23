#!/bin/bash

# Path to the node application
path="$home/$user/web/$domain/private/node"

# Default entrypoint
entrypoint="ecosystem.config.js"
entrypoint_path="$path/$entrypoint"

# Path to the .env file
env_file="$path/.env"

# Load environment variables from the .env file if it exists
if [ -f "$env_file" ]; then
    # Export environment variables from the .env file
    set -a  # Automatically export all variables
    source "$env_file"
    set +a  # Disable automatic export after loading .env
    echo ".env variables loaded."
else
    echo ".env file not found. Proceeding without environment variables."
fi

# Search for the package.json file within the node directory (up to depth 2)
json=$(find "$path" -maxdepth 2 -name package.json -printf "%d %p\n" | sort -n | head -n 1 | cut -d" " -f2-)

# If no package.json is found, return 1
if [ -z "$json" ]; then
    echo "No package.json found in the directory structure."
    return 1
else
    # Extract the 'main' entry point from the package.json file
    entry=$(jq -r ".main" "$json")
    
    # Determine the current working directory
    cwd=$(dirname "$json")
    
    # Output for verification
    echo "Found package.json at: $json"
    echo "Main entry point: $entry"
    echo "Current working directory: $cwd"
fi

# Check if the ecosystem.config.js already exists
if [ ! -f "$entrypoint_path" ]; then
    # Generate the ecosystem.config.js for PM2 only if it doesn't exist
    cat > "$entrypoint_path" <<EOL
module.exports = {
    apps: [{
        name: "$domain",
        cwd: "$cwd",
        script: "$entry",
        instances: "$CLUSTER_NUMBER_OF_INSTANCES",
    }]
}
EOL

    # Set file permissions
    chown $user:$user "$entrypoint_path"
    echo "ecosystem.config.js created at $entrypoint_path"
else
    echo "$entrypoint_path already exists. Skipping creation."
fi

# Check if package.json was found and manage the PM2 app
if [ -n "$json" ]; then
    echo "Configuring PM2 for $domain..."
    # If app is running, restart it, otherwise start it
    runuser -l $user "pm2 delete \"$entrypoint_path\""
    runuser -l $user "pm2 start \"$entrypoint_path\""
    echo "PM2 app for $domain has been restarted or started successfully."
else
    echo "No valid application found. Skipping PM2 management."
fi
