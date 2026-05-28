#!/bin/bash
# clean-term zsh theme installer
# Installs the theme to ~/.oh-my-zsh/custom/themes/

THEME_NAME="clean-term"
THEME_DIR="$HOME/.oh-my-zsh/custom/themes/${THEME_NAME}-omz"
ZSHRC="$HOME/.zshrc"

echo "Installing ${THEME_NAME} zsh theme..."

# Clone the theme if not already installed
if [[ ! -d "$THEME_DIR" ]]; then
  mkdir -p "$HOME/.oh-my-zsh/custom/themes"

  if ! git clone --depth=1 https://github.com/dereklarmstrong/${THEME_NAME}-omz.git "$THEME_DIR"; then
    echo "Error: Failed to clone the theme repository."
    exit 1
  fi
else
  echo "Theme directory already exists at $THEME_DIR, skipping clone."
fi

# Ensure .zshrc exists
if [[ ! -f "$ZSHRC" ]]; then
  touch "$ZSHRC"
fi

# Update .zshrc with theme settings
if grep -q 'ZSH_THEME="clean-term"' "$ZSHRC" 2>/dev/null; then
  echo "ZSH_THEME is already set to '${THEME_NAME}' in ${ZSHRC}"
else
  # Remove any existing ZSH_THEME setting (macOS and Linux compatible)
  sed -i.bak -e '/^ZSH_THEME=/d' "$ZSHRC" 2>/dev/null || sed -i -e '/^ZSH_THEME=/d' "$ZSHRC" 2>/dev/null || true
  rm -f "${ZSHRC}.bak"

  # Remove any existing ZSH_CUSTOM setting
  sed -i.bak -e '/^ZSH_CUSTOM=/d' "$ZSHRC" 2>/dev/null || sed -i -e '/^ZSH_CUSTOM=/d' "$ZSHRC" 2>/dev/null || true
  rm -f "${ZSHRC}.bak"

  echo "" >> "$ZSHRC"
  echo "# Clean-term zsh theme" >> "$ZSHRC"
  echo "ZSH_THEME=\"${THEME_NAME}\"" >> "$ZSHRC"
  echo "ZSH_CUSTOM=\"${THEME_DIR}\"" >> "$ZSHRC"
  echo "Updated ${ZSHRC} with theme settings."
fi

echo ""
echo "Installation complete!"
echo "To activate the theme, restart your terminal or run:"
echo "  source ~/.zshrc"
