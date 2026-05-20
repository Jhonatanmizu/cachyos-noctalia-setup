#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

echo -e "${PURPLE}🌙 CachyOS Noctalia Setup Started${NC}"

REQUIRED_CMDS=(sudo git curl wget fish)
for cmd in "${REQUIRED_CMDS[@]}"; do
  check_command "$cmd" || exit 1
done

if [ "$(id -u)" -eq 0 ]; then
  warning "This script should not be run as root. Please run as a normal user."
  exit 1
fi

# === AUR Helper ===
info "0. Checking for AUR helper..."
if ! is_aur_helper_installed; then
  info "No AUR helper found. Installing yay..."
  sudo pacman -S --noconfirm --needed base-devel git
  TMP_YAY="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$TMP_YAY"
  cd "$TMP_YAY"
  makepkg -si --noconfirm
  cd "$SCRIPT_DIR"
  rm -rf "$TMP_YAY"
  success "yay installed"
else
  info "AUR helper found: $(get_aur_helper)"
fi

# === System Update ===
info "1. Updating System..."
sudo pacman -Syu --noconfirm || {
  error "System update failed"
  exit 1
}

# === Basic Packages ===
info "2. Installing Basic Packages..."
BASIC_PKGS=(
  git
  curl
  wget
  gcc
  make
  fastfetch
  neovim
  bat
)
install_packages "${BASIC_PKGS[@]}"

# === Basic Tools ===
info "3. Installing Basic Tools..."

if ! is_package_installed flatpak; then
  sudo pacman -S --noconfirm flatpak || {
    error "Failed to install flatpak"
    exit 1
  }
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || {
    error "Failed to add Flathub repository"
    exit 1
  }
fi

GUI_PKGS=(
  xournalpp
  gimp
  krita
  inkscape
  kdenlive
  vlc
)
install_packages "${GUI_PKGS[@]}"

info "Installing Flatpak applications..."
FLATPAK_APPS=(
  org.localsend.localsend_app
  md.obsidian.Obsidian
  com.spotify.Client
  com.dropbox.Client
  com.vivaldi.Vivaldi
)

for app in "${FLATPAK_APPS[@]}"; do
  if ! flatpak list --app | grep -q "$app"; then
    flatpak install --noninteractive -y flathub "$app" || {
      warning "Failed to install $app via flatpak"
    }
  else
    info "$app is already installed via flatpak, skipping..."
  fi
done

# === Mise Version Manager ===
info "4. Installing Mise Version Manager..."
if ! command -v mise &> /dev/null; then
  curl -fsSL https://mise.run | sh || {
    error "Failed to install Mise"
    exit 1
  }
  export PATH="$HOME/.local/bin:$PATH"
fi

# === Docker Setup ===
info "5. Installing Docker & Docker Compose..."
install_packages docker docker-compose

sudo systemctl enable --now docker || {
  error "Failed to enable Docker service"
  exit 1
}

sudo usermod -aG docker "$USER" && {
  info "Added $USER to docker group. You'll need to log out and back in for this to take effect."
}

# === VSCode Installation ===
info "6. Installing VSCode..."
if ! is_package_installed code; then
  install_aur_packages visual-studio-code-bin || {
    error "Failed to install VSCode via AUR"
    exit 1
  }
fi

# === Alacritty Installation ===
info "7. Installing Alacritty Terminal..."
install_packages alacritty

# === Create Default Folders ===
info "8. Creating default folders..."
mkdir -p ~/Developer ~/Wallpapers || {
  warning "Failed to create default folders"
}

# === Dotfiles Setup ===
info "9. Loading dotfiles..."
if ! is_package_installed stow; then
  install_packages stow
fi

if [ -f "$(dirname "$0")/stow-dotfiles.sh" ]; then
  bash "$(dirname "$0")/stow-dotfiles.sh" || {
    error "Failed to stow dotfiles"
    exit 1
  }
else
  warning "stow-dotfiles.sh not found, skipping dotfiles setup"
fi

# === Ulauncher Installation ===
info "10. Installing Ulauncher..."
if ! is_package_installed ulauncher; then
  install_aur_packages ulauncher || {
    warning "Failed to install Ulauncher (may not exist in AUR)"
  }
fi

mkdir -p ~/.config/autostart
if [ -f "/usr/share/applications/ulauncher.desktop" ]; then
  cp /usr/share/applications/ulauncher.desktop ~/.config/autostart/ || {
    warning "Failed to copy Ulauncher autostart file"
  }
fi

# === Starship Prompt ===
info "11. Installing Starship shell prompt..."
if ! command -v starship &> /dev/null; then
  curl -fsS https://starship.rs/install.sh | sh -s -- -y || {
    warning "Failed to install Starship via curl, trying pacman..."
    install_packages starship
  }
fi

# === Themes (Noctalia) ===
if [ -f "$(dirname "$0")/scripts/themes.sh" ]; then
  info "12. Installing Noctalia Theme..."
  bash "$(dirname "$0")/scripts/themes.sh" || {
    warning "Failed to install themes"
  }
else
  warning "themes.sh not found, skipping themes setup"
fi

# === Fonts ===
if [ -f "$(dirname "$0")/scripts/fonts.sh" ]; then
  info "13. Installing Fonts..."
  bash "$(dirname "$0")/scripts/fonts.sh" || {
    warning "Failed to install fonts"
  }
else
  warning "fonts.sh not found, skipping fonts setup"
fi

# === Final Message ===
success "✅ CachyOS Noctalia setup complete!"
info "ℹ️ Please restart your terminal or run 'exec fish' to activate your new environment."
info "ℹ️ For Docker permissions, you may need to log out and back in."
