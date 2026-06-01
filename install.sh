#!/usr/bin/env bash
# install.sh — clean-term zsh theme installer
# Usage: bash install.sh

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*" >&2; }

# ── Pre-flight ───────────────────────────────────────────────────────────────

if command -v zsh &>/dev/null; then
    ZSH_PATH="$(command -v zsh)"
else
    error "zsh not found. Install it first:"
    echo "  macOS:   brew install zsh"
    echo "  Linux:   sudo apt install zsh"
    exit 1
fi

OS="$(uname -s)"
case "$OS" in Darwin) OS_NAME="macOS" ;; Linux) OS_NAME="Linux" ;; *) OS_NAME="$OS" ;; esac

# ── TUI Plugin Picker ────────────────────────────────────────────────────────

# Auto-install dialog if missing (for checkbox TUI)
if ! command -v dialog &>/dev/null; then
    info "Installing 'dialog' for TUI..."
    case "$OS" in
        Darwin) brew install dialog ;;
        Linux)  sudo apt-get install -y dialog 2>/dev/null || sudo dnf install -y dialog 2>/dev/null || sudo yum install -y dialog 2>/dev/null ;;
    esac
fi

# Plugin definitions: name|url|description
# Built-in plugins have empty URL
PLUGINS=(
    "git||Basic git commands & aliases"
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git|Predictive autosuggestions"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git|Syntax-aware highlighting"
    "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search.git|Search history with arrow keys"
    "zsh-copyfile|https://github.com/chitoku-g/zsh-copyfile.git|cp preserves timestamps"
    "zsh-compreply|https://github.com/zsh-users/zsh-compreply.git|Advanced completion"
)

NUM_PLUGINS=${#PLUGINS[@]}

# Default: first 3 selected
DEFAULT_CHECKED=(1 1 1 0 0 0)

# ── dialog checkbox TUI ────────────────────────────────────────────────────

CHECKBOXES=""
for ((i=0; i<NUM_PLUGINS; i++)); do
    CHECKBOXES+="$((i+1)) 0 \"${PLUGINS[$i]%|*}\" "
done

TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

dialog --title " clean-term installer " --checklist \
    "Select plugins to install (Space to toggle, Enter to confirm):" \
    14 60 5 \
    $CHECKBOXES \
    2>"$TMPFILE"

if [[ $? -ne 0 ]]; then
    exit 0
fi

SELECTED=()
if [[ -f /tmp/dialog_checklist ]]; then
    DIALOG_OUTPUT="/tmp/dialog_checklist"
else
    DIALOG_OUTPUT="$TMPFILE"
fi
while IFS= read -r line; do
    SELECTED+=("$line")
done < "$DIALOG_OUTPUT"

declare -a PLUGIN_ENABLED=()
for ((i=0; i<NUM_PLUGINS; i++)); do
    found=false
    for s in "${SELECTED[@]}"; do
        if [[ "$s" == "$((i+1))" ]]; then found=true; break; fi
    done
    PLUGIN_ENABLED+=("$found")
done

dialog --title " Summary " --msgbox \
    "Selected: ${SELECTED[*]}\n\nProceed with installation?" \
    8 40

# ── Oh My Zsh ────────────────────────────────────────────────────────────────

OMZ_DIR="$HOME/.oh-my-zsh"

if [[ -d "$OMZ_DIR" ]]; then
    warn "Oh My Zsh already installed at $OMZ_DIR"
    echo ""
    read -p "  Reinstall Oh My Zsh? [y/N] " -r
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        rm -rf "$OMZ_DIR"
        info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        info "Skipping OMZ installation."
    fi
else
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── Plugins ──────────────────────────────────────────────────────────────────

CUSTOM_PLUGINS="$OMZ_DIR/custom/plugins"
mkdir -p "$CUSTOM_PLUGINS"

for ((i=0; i<NUM_PLUGINS; i++)); do
    [[ "${PLUGIN_ENABLED[$i]}" == true ]] || continue

    name="${PLUGINS[$i]%%|*}"
    rest="${PLUGINS[$i]#*|}"
    url="${rest%%|*}"

    if [[ -z "$url" ]]; then
        info "Plugin '$name' is built-in to Oh My Zsh."
    else
        dir="$CUSTOM_PLUGINS/$name"
        if [[ -d "$dir/.git" ]]; then
            warn "Plugin '$name' already installed, skipping."
        else
            info "Installing plugin: $name"
            git clone --depth=1 "$url" "$dir"
        fi
    fi
done

# ── Theme ────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_SRC="$SCRIPT_DIR/themes/clean-term.zsh-theme"
THEME_DST="$OMZ_DIR/themes/clean-term.zsh-theme"

if [[ -f "$THEME_SRC" ]]; then
    cp "$THEME_SRC" "$THEME_DST"
    info "Theme installed."
elif [[ -f "$THEME_DST" ]]; then
    warn "clean-term theme already installed."
else
    error "Could not find clean-term.zsh-theme."
    error "Run this script from the repo root."
    exit 1
fi

# ── .zshrc ───────────────────────────────────────────────────────────────────

ZSHRC="$HOME/.zshrc"

# Build plugins list
plugins_block=""
for ((i=0; i<NUM_PLUGINS; i++)); do
    [[ "${PLUGIN_ENABLED[$i]}" == true ]] || continue
    name="${PLUGINS[$i]%%|*}"
    plugins_block+="    $name"$'\n'
done

if [[ -f "$ZSHRC" ]]; then
    if grep -q 'ZSH_THEME="clean-term"' "$ZSHRC"; then
        warn "ZSH_THEME=\"clean-term\" already in $ZSHRC"
    else
        # Check if this is a fresh OMZ config (contains standard OMZ markers) or user config
        if grep -q 'source \$ZSH/oh-my-zsh.sh' "$ZSHRC" 2>/dev/null || \
           grep -q 'source $ZSH/oh-my-zsh.sh' "$ZSHRC" 2>/dev/null; then
            # Fresh OMZ config — append silently
            {
                echo ""
                echo "# ── clean-term theme ────────────────────────────────────────────────────"
                echo 'ZSH_THEME="clean-term"'
                echo ""
                echo "# ── Plugins ─────────────────────────────────────────────────────────────"
                echo "plugins=("
                printf "%s" "$plugins_block"
                echo ")"
                echo "# ────────────────────────────────────────────────────────────────────────"
            } >> "$ZSHRC"
            info "Added theme + plugins to $ZSHRC"
        else
            # User's existing config — ask
            warn "$ZSHRC already exists."
            echo ""
            read -p "  Append theme + plugin config? [y/N] " -r
            if [[ "$REPLY" =~ ^[Yy]$ ]]; then
                {
                    echo ""
                    echo "# ── clean-term theme ────────────────────────────────────────────────────"
                    echo 'ZSH_THEME="clean-term"'
                    echo ""
                    echo "# ── Plugins ─────────────────────────────────────────────────────────────"
                    echo "plugins=("
                    printf "%s" "$plugins_block"
                    echo ")"
                    echo "# ────────────────────────────────────────────────────────────────────────"
                } >> "$ZSHRC"
                info "Added theme + plugins to $ZSHRC"
            fi
        fi
    fi
else
    cat > "$ZSHRC" <<EOF
# ── clean-term theme ─────────────────────────────────────────────────────
ZSH_THEME="clean-term"

# ── Plugins ────────────────────────────────────────────────────────────────
plugins=(
$(echo -n "$plugins_block")
)
# ────────────────────────────────────────────────────────────────────────────

# Load Oh My Zsh
source "\$HOME/.oh-my-zsh/oh-my-zsh.sh"
EOF
    info "Created $ZSHRC"
fi

# ── Default shell ────────────────────────────────────────────────────────────

CURRENT_USER="${USER:-$(whoami 2>/dev/null || echo "")}"
case "$OS" in
    Darwin) CURRENT_SHELL="$(dscl . -read "$CURRENT_USER" UserShell 2>/dev/null | awk -F': ' '{print $2}')" ;;
    Linux)  CURRENT_SHELL="$(getent passwd "$CURRENT_USER" 2>/dev/null | cut -d: -f7)" ;;
    *)      CURRENT_SHELL="" ;;
esac

if [[ -n "${CURRENT_SHELL:-}" && "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    echo ""
    warn "Your default shell is '$CURRENT_SHELL', not zsh."
    if [[ -t 0 ]]; then
        read -p "  Change default shell to zsh? [y/N] " -r
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            chsh -s "$ZSH_PATH"
            info "Default shell changed to $ZSH_PATH"
        else
            warn "Run 'chsh -s $ZSH_PATH' manually to switch."
        fi
    else
        warn "Run 'chsh -s $ZSH_PATH' manually to switch (non-interactive mode)."
    fi
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${BOLD}${GREEN}╭──────────────────────────────────╮${NC}  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${BOLD}${GREEN}│  clean-term installed!          │${NC}  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${BOLD}${GREEN}│  ${OS_NAME} · $(date '+%Y-%m-%d')              │${NC}  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${BOLD}${GREEN}╰──────────────────────────────────╯${NC}  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Theme: clean-term                                       ${CYAN}║${NC}"

# List selected plugins
plugins_display=""
for ((i=0; i<NUM_PLUGINS; i++)); do
    [[ "${PLUGIN_ENABLED[$i]}" == true ]] || continue
    name="${PLUGINS[$i]%%|*}"
    if [[ -n "$plugins_display" ]]; then plugins_display+=", "; fi
    plugins_display+="$name"
done
if [[ -z "$plugins_display" ]]; then plugins_display="none"; fi

echo -e "${CYAN}║${NC}  Plugins: $plugins_display${NC}                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Config: $ZSHRC${NC}                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${DIM}Restart your terminal or run:${NC}                        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}source $ZSHRC${NC}                                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                         ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
