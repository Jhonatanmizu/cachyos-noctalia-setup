#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
echo -e "${PURPLE}🌙 Installing Noctalia theme (Catppuccin Mocha GTK + Tela icons)...${NC}"

REQUIRED_CMDS=(git gsettings pacman unzip)
missing_cmds=()

for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    missing_cmds+=("$cmd")
  fi
done

if [ ${#missing_cmds[@]} -gt 0 ]; then
  error "Missing required commands: ${missing_cmds[*]}"
  info "Install them with:"
  echo "  sudo pacman -S ${missing_cmds[*]}"
  exit 1
fi

# === 0. Ensure user theme extension is installed ===
info "Checking for User Themes GNOME extension..."
if ! is_package_installed gnome-shell-extension-user-theme; then
  info "Installing gnome-shell-extension-user-theme..."
  install_packages gnome-shell-extension-user-theme
else
  success "User Themes extension already installed"
fi

# === 1. Install Catppuccin Mocha GTK Theme ===
THEME_DIR="$HOME/.themes"
TEMP_THEME="$(mktemp -d)"
mkdir -p "$THEME_DIR"

info "Downloading Catppuccin Mocha GTK theme..."
if ! git clone --depth 1 https://github.com/catppuccin/gtk.git "$TEMP_THEME"; then
  error "Failed to clone Catppuccin GTK repository"
  exit 1
fi

info "Installing Catppuccin Mocha GTK theme..."
cd "$TEMP_THEME"
./install.sh -d "$THEME_DIR" -a mocha -c lavender 2>/dev/null || {
  # fallback: manual install
  mkdir -p "$THEME_DIR/Catppuccin-Mocha"
  cp -r "$TEMP_THEME/release/catppuccin-mocha-lavender-standard+default" "$THEME_DIR/Catppuccin-Mocha" 2>/dev/null || {
    warning "Could not install via install script, trying manual copy..."
    cp -r "$TEMP_THEME"/* "$THEME_DIR/" 2>/dev/null || true
  }
}
cd "$SCRIPT_DIR"
rm -rf "$TEMP_THEME"

# === 2. Install Tela Icon Theme ===
TEMP_TELA="$(mktemp -d)"
info "Downloading Tela icon theme..."

if ! git clone --quiet https://github.com/vinceliuice/Tela-icon-theme.git "$TEMP_TELA"; then
  error "Failed to clone Tela icon theme repository"
  exit 1
fi

info "Installing Tela icon theme..."
if ! "$TEMP_TELA"/install.sh -a; then
  error "Failed to install Tela icon theme"
  rm -rf "$TEMP_TELA"
  exit 1
fi
rm -rf "$TEMP_TELA"

# === 3. Enable User Theme Extension ===
info "Enabling User Themes extension..."

if gnome-extensions list | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
  gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com || warning "Failed to enable user-theme extension. Try enabling it manually in GNOME Tweaks."
  success "User Themes extension enabled"
else
  warning "User Themes extension not found in gnome-extensions list. You may need to log out and back in first."
fi

# === 4. Apply Noctalia Theme ===
info "Applying Noctalia theme settings..."

# Try Catppuccin-Mocha first, then common variations
THEME_NAME="Catppuccin-Mocha"
if [ ! -d "$THEME_DIR/$THEME_NAME" ]; then
  # Look for any catppuccin mocha directory
  THEME_NAME=$(find "$THEME_DIR" -maxdepth 1 -type d -iname "*catppuccin*mocha*" | head -1 | xargs basename 2>/dev/null || echo "")
  if [ -z "$THEME_NAME" ]; then
    THEME_NAME=$(find "$THEME_DIR" -maxdepth 1 -type d -iname "*mocha*" | head -1 | xargs basename 2>/dev/null || echo "Catppuccin-Mocha")
  fi
fi

apply_theme() {
  gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" 2>/dev/null || {
    warning "Failed to set GTK theme to $THEME_NAME"
  }
  gsettings set org.gnome.desktop.wm.preferences theme "$THEME_NAME" 2>/dev/null || {
    warning "Failed to set WM theme"
  }
  gsettings set org.gnome.desktop.interface icon-theme "Tela-dark" 2>/dev/null || {
    warning "Failed to set icon theme"
  }

  if gsettings list-schemas | grep -q "org.gnome.shell.extensions.user-theme"; then
    gsettings set org.gnome.shell.extensions.user-theme name "$THEME_NAME" 2>/dev/null || {
      warning "Failed to set shell theme"
    }
  else
    warning "GNOME Shell user-theme schema not found. Shell theme not applied."
  fi
}

if ! apply_theme; then
  warning "Failed to apply some theme settings (GNOME might not be running)"
fi

# === 5. Verification ===
info "Verifying Noctalia theme installation..."

verify_theme() {
  local current_gtk=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null)
  local current_icons=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null)

  info "Current GTK theme: $current_gtk"
  info "Current icon theme: $current_icons"
}

verify_theme

success "✅ Noctalia theme (Catppuccin Mocha + Tela) installed and applied!"
info "ℹ️ You may need to:"
echo "  - Restart GNOME Shell (Alt+F2, then type 'r' and press Enter)"
echo "  - Or log out and log back in to see full shell theme effect"
echo "  - Ensure 'User Themes' extension is enabled in GNOME Tweaks"
