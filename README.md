# HestiaCP Node.js Setup

This repository provides scripts to simplify the setup and management of a Node.js development environment with HestiaCP. It includes tools like NVM, Node.js, PM2, and template synchronization for Nginx configurations.

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
- **NVM Installation:** Installs the latest version of Node Version Manager (NVM).
- **Node.js Installation:** Sets up the latest Long-Term Support (LTS) version of Node.js via NVM.
- **PM2 Installation:** Installs PM2 globally for managing Node.js applications.
- **Template Synchronization:** Copies Nginx template files from the `./template/` directory to `/usr/local/hestia/data/templates/web/nginx/`.

### Uninstall Script (uninstall.sh)
- Removes NVM and Node.js.
- Uninstalls PM2 globally.
- Deletes synchronized template files from `/usr/local/hestia/data/templates/web/nginx/`.

---

## Prerequisites
- A Linux-based system with Bash installed.
- Administrative privileges to move files and modify system directories.

---

## Usage

### Clone and Download
Run the following command to download and set up the repository:
```
curl -fsSL https://raw.githubusercontent.com/msobiecki/hestiacp-node/main/download.sh | bash
```

### Installation
1. Navigate to the repository directory:
   ```
   cd hestiacp-node
   ```
3. Run the install script:
   ```
   ./install.sh
   ```

### Uninstallation
1. Navigate to the repository directory:
   ```
   cd hestiacp-node
   ```
3. Run the uninstall script:
   ```
   ./uninstall.sh
   ```
