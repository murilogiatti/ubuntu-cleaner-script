# Ubuntu Cleaner & Maintainer (UCM)

[English](#english) | [Português](#português)

---

<a name="english"></a>
## 🚀 Features (English)

A lightweight, dynamic, and automated maintenance script for Ubuntu systems. It combines system-level updates and deep cleaning with user-level maintenance for development tools and browsers.

### System Level (Root)
- **APT:** Updates, upgrades, removes orphans, cleans caches, and purges residual configs.
- **Snap:** Refreshes all snaps and removes old revisions to save disk space.
- **Logs:** Vacuums system journals (keeps last 3 days).
- **Crashes:** Clears the `/var/crash` directory.

### User Level (Dynamic)
- **Dev Tools:** Automatically updates global `npm` packages and `uv` tools.
- **Browsers:** Cleans caches for Google Chrome and Brave Browser.
- **Desktop:** Clears the thumbnail cache.

## 🛠️ Management

1. **Clone the repository:**
   ```bash
   git clone https://github.com/murilogiatti/ubuntu-cleaner-script.git
   cd ubuntu-cleaner-script
   chmod +x *.sh
   ```

2. **Operations:**
   - **Install:** `sudo ./install.sh` (Sets up weekly automation)
   - **Uninstall:** `sudo ./uninstall.sh` (Removes automation and logs)
   - **Update:** `./update.sh` (Pulls latest version from Git and re-installs)

---

<a name="português"></a>
## 🚀 Funcionalidades (Português)

Um script de manutenção leve, dinâmico e automatizado para sistemas Ubuntu. Combina atualizações de nível de sistema e limpeza profunda com manutenção de nível de usuário para ferramentas de desenvolvimento e navegadores.

### Nível de Sistema (Root)
- **APT:** Atualiza, remove órfãos, limpa caches e purga configurações residuais.
- **Snap:** Atualiza todos os snaps e remove revisões antigas para economizar espaço.
- **Logs:** Limpa logs do sistema (mantém os últimos 3 dias).
- **Crashes:** Limpa o diretório `/var/crash`.

### Nível de Usuário (Dinâmico)
- **Ferramentas Dev:** Atualiza pacotes globais `npm` e ferramentas `uv`.
- **Navegadores:** Limpa caches do Google Chrome e Brave Browser.
- **Desktop:** Limpa o cache de miniaturas (thumbnails).

## 🛠️ Gestão

1. **Clonar o repositório:**
   ```bash
   git clone https://github.com/murilogiatti/ubuntu-cleaner-script.git
   cd ubuntu-cleaner-script
   chmod +x *.sh
   ```

2. **Operações:**
   - **Instalar:** `sudo ./install.sh` (Configura automação semanal)
   - **Desinstalar:** `sudo ./uninstall.sh` (Remove automação e logs)
   - **Atualizar:** `./update.sh` (Puxa a versão mais recente do Git e reinstala)

## 📝 About / Sobre

This project provides a CLI alternative to GUI tools like Stacer or BleachBit.
Este projeto fornece uma alternativa via linha de comando para ferramentas gráficas como Stacer ou BleachBit.

## ⚖️ License / Licença

MIT License.
