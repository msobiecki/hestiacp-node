# HestiaCP Node.js Setup

This script installs and manages PM2 applications for Hestia Control Panel (HestiaCP). It provides functionality to:

- Install necessary scripts into HestiaCP's bin directory.
- Setup a cron job to manage PM2 applications.
- Start applications using PM2.
- Uninstall and clean up any changes made during the installation.
- Synchronize Node.js templates for Nginx.

---

## Repository
Clone this repository from GitHub:
```
git clone git@github.com:msobiecki/hestiacp-node.git
cd hestiacp-node
```

---

## Features

### Install Script (install.sh)
- **Install NVM (Node Version Manager):** Installs the latest version of NVM, which allows managing multiple Node.js versions.
- **Install Node.js:** Sets up the latest Long-Term Support (LTS) version of Node.js via NVM.
- **Install PM2:** Installs PM2 globally for managing Node.js applications.
- **Synchronize Nginx Templates:** Copies Node.js-related Nginx templates from the repository's `./template/` directory to`/usr/local/hestia/data/templates/web/nginx/`.
- **Set up the PM2 management script:** Adds `v-start-pm2` and `v-start-all-pm2` scripts to the HestiaCP bin directory for managing Node.js applications via PM2..

### Uninstall Script (uninstall.sh)
- **Remove NVM and Node.js**: Deletes Node Version Manager and the installed Node.js version.
- **Uninstall PM2 globally**: Removes PM2 from the system.
- **Clean up synchronized templates**: Deletes any modified or added templates from `/usr/local/hestia/data/templates/web/nginx/`.
- **Remove installed PM2 scripts**: Deletes the `v-start-pm2` and `v-start-all-pm2` scripts from HestiaCP’s bin directory.

### Cron Job Setup
- **`start-all-pm2` cron job**: The install script adds a cron job to /etc/cron.d/ that ensures all PM2 applications are started at specified intervals.
- **Automatic Node.js Application Management**: The cron job will automatically start all applications managed by PM2 on a set schedule, ensuring that any Node.js apps that are supposed to run continuously are kept alive.

---

## Prerequisites
Before running the installation script, ensure the following:

- A Linux-based system with Bash installed.
- Administrative privileges to move files and modify system directories (e.g., using sudo).
- HestiaCP must be installed and configured on your server.
- Node.js applications are set up in the correct user directories.

---

## Usage

### Clone and Download
To download the repository and run the setup script, execute the following command:
```
curl -fsSL https://raw.githubusercontent.com/msobiecki/hestiacp-node/refs/heads/master/install.sh | bash
```
This command will download and automatically execute the `install.sh` script from the repository.

### Installation
1. Navigate to the repository directory:
   ```
   cd hestiacp-node
   ```
3. Run the install script:
   ```
   sudo ./install.sh
   ```

   The script will:

   - Install NVM and the latest LTS version of Node.js.
   - Install PM2 globally for managing Node.js applications.
   - Sync the necessary Nginx templates.
   - Add the required scripts to HestiaCP's bin directory.
   - Set up a cron job to ensure that all PM2 apps are managed properly.

### Uninstallation
1. Navigate to the repository directory:
   ```
   cd hestiacp-node
   ```
3. Run the uninstall script:
   ```
   sudo ./uninstall.sh
   ```

   The uninstall script will:

   - Remove NVM, Node.js, and PM2.
   - Clean up the synchronized Nginx templates.
   - Remove any added scripts from /usr/local/hestia/bin/.
   - Delete the cron job managing PM2 applications.
  
## PM2 Management Scripts

- `v-start-pm2`: This script starts the Node.js applications configured for each user and domain in HestiaCP. It will loop through all users and their domains, detecting any Node.js applications and starting them with PM2.
- `v-start-all-pm2`: This script starts all Node.js applications managed by PM2, regardless of the user or domain.

These scripts are installed into the `/usr/local/hestia/bin/` directory and are accessible from the command line.

## Cron Job

The cron job installed by the script runs at scheduled intervals to ensure that PM2 applications are automatically started and kept running. This is crucial for applications that need to stay alive continuously.

The cron job is installed in `/etc/cron.d/start-all-pm2`.

## Example Use Cases

### Starting Node.js Application with PM2
1. To start a specific Node.js application for a user/domain, you can use the `v-start-pm2` script:

```
sudo v-start-pm2
```

This command will start all Node.js applications for all users and domains that are configured with Node.js.

2. To start all Node.js applications across all users and domains, use the `v-start-all-pm2` script:
```
sudo v-start-all-pm2
```
This command ensures that all applications are managed and started by PM2, keeping everything running.

### Automating Application Management with Cron Jobs
- The **cron job** will ensure that all PM2 applications are restarted if they stop, keeping your applications running as expected.
- You can view and edit the cron job by modifying `/etc/cron.d/start-all-pm2`.

## Troubleshooting

- If the script fails or encounters issues, check the PM2 logs for more information:

```
pm2 logs
```

- Ensure that all required directories exist for the user/domain configurations and that the applications are set up correctly.
- Verify that the cron job is running by checking its status:
```
sudo crontab -l
```
- If you encounter permission issues, make sure the scripts in `/usr/local/hestia/bin/` have the correct executable permissions.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

Feel free to contribute to this repository by opening issues or submitting pull requests. Happy coding!
