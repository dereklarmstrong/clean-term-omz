#!/usr/bin/env bash
# install.sh — clean-term zsh theme installer
# Usage: bash install.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*" >&2; }

# ── Pre-flight ───────────────────────────────────────────────────────────────

if ! command -v zsh &>/dev/null; then
    error "zsh not found. Install it first:"
    echo "  macOS:   brew install zsh"
    echo "  Linux:   sudo apt install zsh"
    exit 1
fi

ZSH_PATH="$(command -v zsh)"

# ── Oh My Zsh ────────────────────────────────────────────────────────────────

OMZ_DIR="$HOME/.oh-my-zsh"

if [[ -d "$OMZ_DIR" ]]; then
    info "Oh My Zsh already installed."
else
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── Plugins ──────────────────────────────────────────────────────────────────

CUSTOM_PLUGINS="$OMZ_DIR/custom/plugins"
mkdir -p "$CUSTOM_PLUGINS"

# External plugins (git is built-in to OMZ)
declare -A EXTERNAL_PLUGINS=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
)

for name in "${!EXTERNAL_PLUGINS[@]}"; do
    dir="$CUSTOM_PLUGINS/$name"
    if [[ -d "$dir/.git" ]]; then
        info "Plugin '$name' already installed."
    else
        info "Installing plugin: $name"
        git clone --depth=1 "${EXTERNAL_PLUGINS[$name]}" "$dir"
    fi
done

# ── Theme ────────────────────────────────────────────────────────────────────

THEME_DST="$OMZ_DIR/themes/clean-term.zsh-theme"

if [[ -f "$THEME_DST" ]]; then
    warn "clean-term theme already installed."
else
    info "Installing theme..."
    cp "$(dirname "$0")/themes/clean-term.zsh-theme" "$THEME_DST"
    info "Theme installed."
fi

# ── .zshrc ───────────────────────────────────────────────────────────────────

ZSHRC="$HOME/.zshrc"
PLUGINS_LIST="git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search"

if [[ -f "$ZSHRC" ]]; then
    if grep -q 'ZSH_THEME="clean-term"' "$ZSHRC"; then
        warn "ZSH_THEME=\"clean-term\" already in $ZSHRC"
    else
        # Remove old clean-term block if it exists
        sed -i.bak '/# clean-term/,/# end clean-term/d' "$ZSHRC" 2>/dev/null || true

        {
            echo ""
            echo "# clean-term theme"
            echo 'ZSH_THEME="clean-term"'
            echo ""
            echo "# plugins"
            echo "plugins=($PLUGINS_LIST)"
            echo "# end clean-term"
        } >> "$ZSHRC"
        info "Added theme + plugins to $ZSHRC"
    fi
else
    cat > "$ZSHRC" <<EOF
# clean-term theme
ZSH_THEME="clean-term"

# plugins
plugins=($PLUGINS_LIST)
# end clean-term

# Load Oh My Zsh
source "\$HOME/.oh-my-zsh/oh-my-zsh.sh"
EOF
    info "Created $ZSHRC"
fi

# ── Default shell ────────────────────────────────────────────────────────────

CURRENT_USER="${USER:-$(whoami 2>/dev/null || echo "")}"
CURRENT_SHELL=""
case "$(uname -s)" in
    Darwin) CURRENT_SHELL="$(dscl . -read "$CURRENT_USER" UserShell 2>/dev/null | awk -F': ' '{print $2}')" ;;
    Linux)  CURRENT_SHELL="$(getent passwd "$CURRENT_USER" 2>/dev/null | cut -d: -f7)" ;;
esac

if [[ -n "${CURRENT_SHELL:-}" && "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    warn "Your default shell is '$CURRENT_SHELL', not zsh."
    if [[ -t 0 ]]; then
        read -p "  Change default shell to zsh? [y/N] " -r
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            chsh -s "$ZSH_PATH"
            info "Default shell changed to $ZSH_PATH"
        fi
    fi
fi

echo ""
info "clean-term installed!"
echo "  Config: $ZSHRC"
echo "  Restart your terminal or run: source $ZSHRC"
echo ""
