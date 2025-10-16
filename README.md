# 🐳 Universal Docker Installer & Uninstaller

Welcome to your **Docker Swiss Army Knife** for Linux! 🛠️  
These scripts help you **install, configure, and completely remove Docker** across **Ubuntu**, **Fedora**, and **Arch Linux** — quickly, cleanly, and even a little humorously 😎

---

## ✨ Features

- 🚀 One-line install for Docker Engine + Compose  
- 👤 Adds your chosen user for **non-root** Docker use  
- 🔄 Enables Docker to start automatically on boot  
- 🧭 Optional **web-based GUI** installer (Portainer, Yacht, Dockge)  
- 🧹 Universal uninstaller that removes *everything* Docker created — configs, images, volumes, caches, keys, and repos  

---

## 🧰 Included Scripts

### 🔹 Install Scripts
| Distro | Script |
|--------|---------|
| Ubuntu | `docker-install-ubuntu.sh` |
| Fedora | `docker-install-fedora.sh` |
| Arch   | `docker-install-arch.sh`   |

Each installer:
- Installs Docker Engine + Compose  
- Adds your username to the Docker group  
- Enables autostart  
- Asks which **GUI** you’d like (or none at all!)

---

### 🔹 Uninstall Scripts
| Type | Script |
|------|---------|
| ✅ Universal | `uninstall-docker-universal.sh` |
| Ubuntu | `uninstall-docker-complete.sh` |
| Fedora | `uninstall-docker-fedora.sh` |
| Arch | `uninstall-docker-arch.sh` |

> 💡 Start with the **universal** uninstaller.  
> If anything’s left behind, use your distro’s specific script.

Each uninstaller:
- Stops all Docker services  
- Removes containers, images, volumes, and networks  
- Deletes config folders, repos, and GPG keys  
- Cleans cache & removes the Docker group  

---

## ⚙️ Usage

1. **Make script executable**
   ```bash
   chmod +x script-name.sh
   ```

2. **Run script**
   ```bash
   ./script-name.sh
   ```

3. Follow the prompts:
   - Enter your username (for non-root use)
   - Choose whether to install a GUI
   - Sit back and enjoy the automation 🎩

4. **Re-login** (or restart) for user group changes to take effect.

---

## ⚠️ What NOT to Do
- ❌ Don’t mix scripts across distros (Fedora ≠ Ubuntu ≠ Arch).  
- ❌ Don’t uninstall unless you’re ready to lose **all** Docker data.  
- ❌ Don’t skip the username prompt — or you’ll be stuck using `sudo`.  

---

## 😎 GUI Options

| GUI | Description |
|-----|--------------|
| **Portainer** | Full-featured Docker dashboard |
| **Yacht** | Sleek, minimal interface |
| **Dockge** | Built for `docker-compose` lovers |

> “With great Docker power comes great `docker system prune -af` responsibility.” 💥

---

## 🧩 Quick Reference

| OS | Install Script | Uninstall Script |
|----|----------------|-----------------|
| Ubuntu | `docker-install-ubuntu.sh` | `uninstall-docker-complete.sh` |
| Fedora | `docker-install-fedora.sh` | `uninstall-docker-fedora.sh` |
| Arch | `docker-install-arch.sh` | `uninstall-docker-arch.sh` |
| All | — | `uninstall-docker-universal.sh` |

---

## ❤️ Credits

Created with ☕, ⚙️, and a dash of sarcasm by Linux enthusiasts who believe setup should be **one command away**.

---

## 📜 License
This project is open-source under the **MIT License** — modify, share, and improve freely.  

---

> 🧠 *Docker responsibly. Script smart. And remember — backups are cheaper than tears.*
