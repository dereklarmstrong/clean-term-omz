#!/bin/bash
# clean-term zsh theme installer
# Installs the theme to ~/.oh-my-zsh/custom/themes/

set -e

THEME_NAME="clean-term"
THEME_DIR="$HOME/.oh-my-zsh/custom/themes/${THEME_NAME}-omz"
ZSHRC="$HOME/.zshrc"

echo "Installing ${THEME_NAME} zsh theme..."

# Clone the theme if not already installed
if [[ ! -d "$THEME_DIR" ]]; then
  mkdir -p "$HOME/.oh-my-zsh/custom/themes"
  git clone --depth=1 https://github.com/dereklarmstrong/${THEME_NAME}-omz.git "$THEME_DIR" 2>/dev/null
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to clone the theme repository."
    exit 1
  fi
else
  echo "Theme directory already exists at $THEME_DIR"
fi

# Update ZSH_RC file with theme settings
if grep -q 'ZSH_THEME="clean-term"' "$ZSHRC" 2>/dev/null; then
  echo "ZSH_THEME is already set to '${THEME_NAME}' in ${ZSHRC}"
else
  # Remove any existing ZSH_THEME setting
  sed -i '' "/^ZSH_THEME=/d" "$ZSHRC" 2>/dev/null || true
  echo "" >> "$ZSHRC"
  echo "# Clean-term zsh theme" >> "$ZSHRC"
  echo "ZSH_THEME=\"${THEME_NAME}\"" >> "$ZSHRC"
  echo "ZSH_CUSTOM=\"${THEME_DIR}\"" >> "$ZSHRC"
fi

echo "Installation complete!"
echo ""
echo "To activate the theme, restart your terminal or run:"
echo "  source ~/.zshrc"
