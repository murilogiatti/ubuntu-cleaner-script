# Ubuntu Cleaner & Maintainer (UCM)

A lightweight, dynamic, and automated maintenance script for Ubuntu systems. It combines system-level updates and deep cleaning with user-level maintenance for development tools and browsers.

## 🚀 Features

### System Level (Root)
- **APT:** Updates, upgrades, removes orphans, cleans caches, and purges residual configs.
- **Snap:** Refreshes all snaps and removes old, disabled revisions to save disk space.
- **Logs:** Vacuums system journals (keeps last 3 days).
- **Crashes:** Clears the `/var/crash` directory.

### User Level (Dynamic)
- **Dev Tools:** Automatically updates global `npm` packages and `uv` tools.
- **Browsers:** Cleans caches for Google Chrome and Brave Browser without affecting history or passwords.
- **Desktop:** Clears the thumbnail cache.

## 🛠️ Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/ubuntu-cleaner-script.git
   cd ubuntu-cleaner-script
   ```

2. **Make the script executable:**
   ```bash
   chmod +x ucm.sh
   ```

3. **Run it manually:**
   ```bash
   sudo ./ucm.sh
   ```

### 📅 Automatic Weekly Maintenance

To run this script automatically every week:

```bash
sudo cp ucm.sh /etc/cron.weekly/ucm
sudo chown root:root /etc/cron.weekly/ucm
sudo chmod 755 /etc/cron.weekly/ucm
```

## 📝 About

This project was created to provide a simple, command-line alternative to GUI tools like Stacer or BleachBit, focusing on safety and common Ubuntu maintenance tasks.

## ⚖️ License

Distributed under the MIT License. See `LICENSE` for more information.
