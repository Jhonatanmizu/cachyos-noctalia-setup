#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
FONT_DIR="${HOME}/.local/share/fonts"
TMP_DIR="$(mktemp -d)"
NERD_FONT_REPO="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
FONTS=("FiraCode" "Meslo")

REQUIRED_CMDS=(curl unzip fc-cache find)
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

install_fonts() {
  mkdir -p "${FONT_DIR}"
  cd "$TMP_DIR"

  for font in "${FONTS[@]}"; do
    info "Downloading ${font} Nerd Font..."
    archive="${font}.zip"
    url="${NERD_FONT_REPO}/${archive}"

    if curl -fsSLO "$url"; then
      info "Extracting ${archive}..."
      unzip -q "$archive" -d "${FONT_DIR}"
      success "${font} installed to ${FONT_DIR}"
    else
      warning "Failed to download ${font} from ${url}"
    fi
  done
}

verify_fonts() {
  local fonts_installed=0
  info "Verifying font installation..."

  for font in "${FONTS[@]}"; do
    if find "$FONT_DIR" -iname "*${font}*" -print -quit | grep -q .; then
      success "Found ${font} font files"
      ((fonts_installed++))
    else
      warning "Could not find ${font} font files"
    fi
  done

  if [ "$fonts_installed" -eq 0 ]; then
    error "No fonts were installed"
    return 1
  fi
}

refresh_font_cache() {
  info "Refreshing font cache..."
  if fc-cache -fv > /dev/null; then
    success "Font cache updated"
  else
    warning "Font cache refresh failed"
  fi
}

cleanup() {
  rm -rf "$TMP_DIR"
}

echo -e "${PURPLE}🔤 Installing Nerd Fonts from official GitHub releases...${NC}"
install_fonts
refresh_font_cache
cleanup

echo -e "\n${PURPLE}=== Font Installation Summary ===${NC}"
if verify_fonts; then
  success "✅ Nerd Fonts installed successfully!"
  info "You may need to:"
  echo "  - Restart terminal applications to use the new fonts"
  echo "  - Configure your terminal emulator to use the installed fonts"
else
  warning "Some fonts may not have installed correctly"
  info "Try downloading and installing them manually from:"
  echo "  https://github.com/ryanoasis/nerd-fonts/releases"
fi
