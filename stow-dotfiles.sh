#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
echo -e "${PURPLE}📦 Loading dotfiles with GNU Stow...${NC}"

REQUIRED_CMDS=(git stow)
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

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

mkdir -p "$(dirname "$DOTFILES_DIR")"

if [ ! -d "$DOTFILES_DIR" ]; then
  info "Cloning dotfiles repository into $DOTFILES_DIR..."
  if git clone https://github.com/jhonatanmizu/dotfiles.git "$DOTFILES_DIR"; then
    success "Repository cloned successfully"
  else
    error "Failed to clone dotfiles repository"
    exit 1
  fi
else
  info "Dotfiles directory already exists at $DOTFILES_DIR"
fi

cd "$DOTFILES_DIR" || { error "Failed to access $DOTFILES_DIR"; exit 1; }

if [ -d ".git" ]; then
  info "Updating dotfiles repository..."
  if ! git pull --quiet --rebase; then
    warning "Failed to update dotfiles repository (continuing with existing version)"
  fi
fi

MODULES=("zsh" "git" "nvim" "alacritty" "mise" "starship" "ulauncher")
stowed_modules=()
skipped_modules=()

for module in "${MODULES[@]}"; do
  if [ ! -d "$module" ]; then
    warning "Module '$module' not found - skipping"
    skipped_modules+=("$module")
    continue
  fi

  info "Stowing module: $module"
  if stow --restow --target="$HOME" "$module" 2>/dev/null; then
    success "Successfully stowed $module"
    stowed_modules+=("$module")
  else
    warning "Failed to stow $module (conflicts may exist)"
    skipped_modules+=("$module")
  fi
done

echo -e "\n${PURPLE}📋 Stow Summary:${NC}"
echo -e "${GREEN}✅ Successfully stowed: ${#stowed_modules[@]} modules${NC}"
printf ' - %s\n' "${stowed_modules[@]}"

if [ ${#skipped_modules[@]} -gt 0 ]; then
  echo -e "${YELLOW}⚠  Skipped: ${#skipped_modules[@]} modules${NC}"
  printf ' - %s\n' "${skipped_modules[@]}"
fi

if [ ${#stowed_modules[@]} -gt 0 ]; then
  success "✅ Dotfiles successfully stowed!"
else
  warning "No modules were stowed - check for errors above"
  exit 1
fi
