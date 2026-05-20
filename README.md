# 🌙 CachyOS Noctalia Dev Setup

A simple, fast, and opinionated shell script to quickly set up a CachyOS-based
development environment with the **Noctalia** dark theme. It automates the
installation of essential tools, configures dotfiles using `stow`, and provides
a clean, consistent developer experience across machines.

---

## 🎯 Purpose

This project was created to streamline the setup of my personal development
environment on CachyOS. It automates the installation of my most-used applications,
CLI tools, and desktop customizations — ensuring a consistent, reliable, and
ready-to-code system in minutes.

---

## ⚙️ Features

- 📦 Install essential packages and development tools (pacman + AUR)
- 🧰 Set up Flatpak and configure the Flathub remote
- 🛠️ Apply dotfiles using GNU `stow` (modular config management)
- 🪟 Configure Niri compositor with Noctalia styling
- 🌙 **Noctalia** dark theme (Catppuccin Mocha GTK + Tela icons)
- 🧼 Clean, minimal, and fully modular – each setup task is in its own script

---

## 📋 Tools & Apps Installed

### 🧩 Development Tools

- `git`, `curl`, `wget`, `gcc`, `make`
- `neovim` – Advanced text editor
- `bat`, `fastfetch` – CLI utilities
- `Docker` & `Docker Compose`
- `VSCode` & `Android Studio` (via AUR)
- `mise` – Version manager
- `starship` – Prompt customizer

### 🖼️ Noctalia Theme

- **Noctalia theme**: Catppuccin Mocha (GTK) + Tela Dark (icons)
- Applied via GTK settings.ini (works with Niri or any Wayland compositor)

### 📁 Utilities & GUI Tools

- `xournalpp` – PDF annotation
- `localsend` – Local file sharing
- `gimp`, `krita`, `inkscape`, `kdenlive`, `vlc`
- Flatpak apps: Obsidian, Spotify, Dropbox, Vivaldi

---

## 🧩 Dotfiles

Dotfiles are managed using [GNU Stow](https://www.gnu.org/software/stow/) for
clean and modular configuration. Current modules include:

- `fish`, `git`, `nvim`, `alacritty`, `mise`, `starship`, `ulauncher`

You can easily add or remove modules from your dotfiles repo.

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Jhonatanmizu/cachyos-noctalia-setup.git
cd cachyos-noctalia-setup
```

### 2. Run the main setup script

```bash
chmod +x setup.sh
./setup.sh
```

☑️ This will install packages, apply the Noctalia theme, load dotfiles, and more.

## 🗃️ Repository Structure

```bash
cachyos-noctalia-setup/
├── dotfiles/             # Dotfiles to be stowed
├── scripts/              # Sub-scripts for fonts, theme installation
├── setup.sh              # Main setup entry point
├── stow-dotfiles.sh      # Dotfile manager using GNU Stow
└── README.md
```

## 🧠 Requirements

- ✅ CachyOS Linux (Arch-based)
- ✅ Internet connection
- ✅ sudo privileges
- ✅ Niri compositor (or any Wayland compositor)

## 📝 Notes

- Flatpak is preferred over Snap. This setup avoids using Snap entirely.
- Niri is the target compositor, but scripts work on any Wayland setup.
- AUR helper (yay) is automatically installed if not present.

## 🤝 Contributing

Found a bug or want to suggest improvements? Feel free to fork the project,
open an issue, or submit a pull request.

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for more
details.
