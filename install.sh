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

# ── Theme ────────────────────────────────────────────────────────────────────

THEME_DST="$OMZ_DIR/themes/clean-term.zsh-theme"

if [[ -f "$THEME_DST" ]]; then
    warn "clean-term theme already installed."
else
    info "Installing theme..."
    cp "$(dirname "$0")/themes/clean-term.zsh-theme" "$THEME_DST"
    info "Theme installed."
fi

# ── Plugin Options ───────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}Plugins (optional — just my personal preferences)${NC}"
echo "The theme works fine without them. Pick any you want:"
echo ""
echo "  1) zsh-autosuggestions        — type-ahead predictions"
echo "  2) zsh-syntax-highlighting    — real-time syntax color"
echo "  3) zsh-history-substring-search — search history with arrows"
echo "  4) zsh-copyfile               — cp preserves timestamps"
echo "  5) zsh-compreply              — advanced completion"
echo ""
echo "  [Enter] to skip all"
echo ""

read -p "  Plugin numbers (comma-separated, e.g. 1,2,3): " -r PLUGIN_INPUT
PLUGIN_INPUT="${PLUGIN_INPUT// /}"

declare -A EXTERNAL_PLUGINS=(
    [1]="zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git"
    [2]="zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
    [3]="zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search.git"
    [4]="zsh-copyfile|https://github.com/chitoku-g/zsh-copyfile.git"
    [5]="zsh-compreply|https://github.com/zsh-users/zsh-compreply.git"
)

CUSTOM_PLUGINS="$OMZ_DIR/custom/plugins"
mkdir -p "$CUSTOM_PLUGINS"

SELECTED_PLUGINS=()

if [[ -n "$PLUGIN_INPUT" ]]; then
    IFS=',' read -ra NUMS <<< "$PLUGIN_INPUT"
    for num in "${NUMS[@]}"; do
        if [[ -n "${EXTERNAL_PLUGINS[$num]:-}" ]]; then
            IFS='|' read -r name url <<< "${EXTERNAL_PLUGINS[$num]}"
            SELECTED_PLUGINS+=("$name")
            dir="$CUSTOM_PLUGINS/$name"
            if [[ -d "$dir/.git" ]]; then
                info "Plugin '$name' already installed."
            else
                info "Installing plugin: $name"
                git clone --depth=1 "$url" "$dir"
            fi
        else
            warn "Unknown plugin number: $num"
        fi
    done
fi

# ── .zshrc ───────────────────────────────────────────────────────────────────

ZSHRC="$HOME/.zshrc"

# Always include git (OMZ built-in), plus any selected plugins
PLUGINS_LIST="git"
for p in "${SELECTED_PLUGINS[@]}"; do
    PLUGINS_LIST+=" $p"
done

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
            echo "# plugins (add/remove as you like)"
            echo "plugins=($PLUGINS_LIST)"
            echo "# end clean-term"
        } >> "$ZSHRC"
        info "Added theme + plugins to $ZSHRC"
    fi
else
    cat > "$ZSHRC" <<EOF
# clean-term theme
ZSH_THEME="clean-term"

# plugins (add/remove as you like)
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
