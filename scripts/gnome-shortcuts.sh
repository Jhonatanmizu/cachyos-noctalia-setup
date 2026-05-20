#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
echo -e "\n${PURPLE}=== GNOME Workspace & Keybinding Configuration ===${NC}"

info "Disabling dynamic workspaces and setting fixed count to 6..."
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6
success "Workspace configuration applied"

info "Disabling default Super+Number application switching..."
for i in {1..9}; do
  gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done
success "Super+Number application bindings disabled"

info "Mapping Super+Number to workspace switching..."
for i in {1..6}; do
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
done
success "Workspace keybindings configured"

info "Setting Super+W as shortcut to close windows..."
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>w']"
success "Close shortcut remapped"

echo -e "\n${PURPLE}✓ All GNOME settings applied successfully.${NC}"
