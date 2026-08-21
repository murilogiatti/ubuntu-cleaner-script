# Ubuntu Cleaner & Maintainer (UCM)

[English](#english) | [Português](#português)

---

<a name="english"></a>
## 🚀 Features (English)

A lightweight, dynamic, modular, and automated system maintenance and disk space recovery tool for Ubuntu and Debian-based systems. It combines system-level updates and deep package cleaning with user-level maintenance for development environments, GPU shaders, browsers, and caches.

### 🛡️ System Level (Root)
- **APT:** Updates package indexes, upgrades packages, removes orphaned dependencies (`autoremove --purge`), cleans APT caches, and purges residual configurations (`rc` packages).
- **Snap:** Updates all snaps and automatically removes old disabled revisions to reclaim disk space.
- **Flatpak:** Updates all Flatpak runtimes/apps and uninstalls unused runtimes (`flatpak uninstall --unused`).
- **Logs & Diagnostics:** Vacuums systemd journal logs (keeps last 3 days) and empties `/var/crash`.

### 👤 User Level (Dynamic per User)
- **Developer Caches & Tools:**
  - **Python:** Cleans Python `uv` cache and `pip` wheel caches.
  - **Node.js / JS:** Cleans `npm` cache (`npm cache clean --force`), `~/.npm/_cacache`, `yarn`, `pnpm`, and `bun` caches.
  - **IDE:** Cleans VS Code / VSCodium `Cache`, `CachedData`, and `vscode-ripgrep`.
  - **Docker:** Prunes unused containers, networks, dangling images, and build cache (`docker system prune -f`).
  - **Package Updates:** Upgrades global `npm` packages and `uv` CLI tools (`uv tool upgrade --all`).
- **Deep Browser Cache Cleaning:**
  - Full multi-profile deep cleaning for **Google Chrome**, **Brave Browser**, **Microsoft Edge**, **Chromium**, and **Mozilla Firefox / LibreWolf**.
  - Targets `Cache`, `Code Cache` (compiled V8 JS/WASM bytecode), `GPUCache`, `DawnWebGPUCache`, `DawnGraphiteCache`, `Service Worker/CacheStorage`, and extension caches.
- **GPU Shader Caches:**
  - Cleans **Mesa / OpenGL** (`~/.cache/mesa_shader_cache`), **AMD / RADV Vulkan** (`~/.cache/radv_builtin_shaders`), and **NVIDIA** (`~/.nv/GLCache` and `~/.cache/nvidia`). Shaders are automatically regenerated on-demand by drivers.
- **Desktop & Storage:**
  - Empties user thumbnail cache (`~/.cache/thumbnails`).
  - Safely empties the user Trash (`~/.local/share/Trash`).

---

## 🛠️ Command-Line Options

| Flag | Description |
|------|-------------|
| `-d`, `--dry-run` | Show what would be done without performing any destructive actions. |
| `-v`, `--verbose` | Enable Bash tracing (`set -x`) for detailed debugging output. |
| `-u USER`, `--user USER` | Specify the target non‑root user for user‑level maintenance. |
| `--log FILE` | Write the log to the specified `FILE` (default `/var/log/ucm_maintenance.log`). |
| `--skip-apt` | Skip the APT maintenance stage. |
| `--skip-snap` | Skip the Snap maintenance stage. |
| `--skip-flatpak` | Skip the Flatpak maintenance stage. |
| `--skip-user` | Skip user‑level maintenance entirely. |
| `--skip-dev` | Skip developer caches cleanup (UV, Pip, Node, VS Code, Docker). |
| `--skip-gpu` | Skip GPU shader caches cleanup (Mesa, RADV, NVIDIA). |
| `--skip-trash` | Skip emptying user trash. |
| `-y`, `--yes`, `--non-interactive` | Assume yes for prompts (intended for cron/systemd automation). |
| `--report FILE` | Generate an HTML report of the run at `FILE`. |
| `-h`, `--help` | Show usage information. |

---

## 📦 Installation & Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/murilogiatti/ubuntu-cleaner-script.git
   cd ubuntu-cleaner-script
   chmod +x *.sh
   ```

2. **Operations:**
   - **Install:** `sudo ./install.sh` (Installs under `/usr/local/lib/ucm`, creates `/usr/local/sbin/ucm.sh`, and sets up weekly cron automation)
   - **Uninstall:** `sudo ./uninstall.sh` (Removes cron automation, binaries, and logs)
   - **Update:** `./update.sh` (Pulls latest version from Git and reinstalls)
   - **Interactive Run:** `sudo ./ucm.sh`
   - **Non-interactive / Automated:** `sudo ./ucm.sh --yes`
   - **Dry Run (Simulation):** `sudo ./ucm.sh --dry-run --yes`
   - **Generate HTML Report:** `sudo ./ucm.sh --yes --report /tmp/ucm-report.html`

---

<a name="português"></a>
## 🚀 Funcionalidades (Português)

Uma ferramenta de manutenção e recuperação de espaço em disco leve, dinâmica, modular e automatizada para Ubuntu e distribuições baseadas em Debian. Combina atualizações e limpeza profunda do sistema com manutenção de ambientes de desenvolvimento, shaders de GPU, navegadores e caches de usuário.

### 🛡️ Nível de Sistema (Root)
- **APT:** Atualiza repositórios, atualiza pacotes, remove dependências órfãs (`autoremove --purge`), limpa caches e purga arquivos de configuração residuais (`status rc`).
- **Snap:** Atualiza todos os snaps e remove revisões antigas desabilitadas para liberar espaço em disco.
- **Flatpak:** Atualiza pacotes Flatpak e desinstala runtimes órfãos não utilizados (`flatpak uninstall --unused`).
- **Logs & Diagnósticos:** Compacta logs do journalctl (mantém últimos 3 dias) e limpa `/var/crash`.

### 👤 Nível de Usuário (Dinâmico por Usuário)
- **Caches e Ferramentas de Desenvolvimento:**
  - **Python:** Limpa cache do `uv` e caches de wheels do `pip`.
  - **Node.js / JS:** Limpa cache do `npm` (`npm cache clean --force`), `~/.npm/_cacache`, `yarn`, `pnpm` e `bun`.
  - **IDE:** Limpa caches do VS Code e VSCodium (`Cache`, `CachedData`, `vscode-ripgrep`).
  - **Docker:** Remove containers parados, imagens órfãs e build cache (`docker system prune -f`).
  - **Atualização de Pacotes:** Atualiza pacotes globais `npm` e ferramentas isoladas `uv` (`uv tool upgrade --all`).
- **Limpeza Profunda de Navegadores:**
  - Limpeza completa multi-perfil para **Google Chrome**, **Brave Browser**, **Microsoft Edge**, **Chromium** e **Mozilla Firefox / LibreWolf**.
  - Remove `Cache`, `Code Cache` (bytecode V8 JS/WASM compilado), `GPUCache`, `DawnWebGPUCache`, `DawnGraphiteCache`, `Service Worker/CacheStorage` e extensões temporárias.
- **Shaders de Placa de Vídeo (GPU):**
  - Limpa caches de shaders **Mesa / OpenGL** (`~/.cache/mesa_shader_cache`), **AMD / RADV Vulkan** (`~/.cache/radv_builtin_shaders`) e **NVIDIA** (`~/.nv/GLCache`, `~/.cache/nvidia`). Os shaders são recriados automaticamente sob demanda.
- **Desktop & Armazenamento:**
  - Esvazia cache de miniaturas (`~/.cache/thumbnails`).
  - Esvazia a lixeira do usuário com segurança (`~/.local/share/Trash`).

---

## 📝 About / Sobre

**Ubuntu Cleaner & Maintainer (UCM)** is a modern, modular CLI alternative to traditional GUI cleaners like Stacer, BleachBit, or Kudu, designed for high performance, server/desktop automation, and zero bloat.

## ⚖️ License / Licença

MIT License.
