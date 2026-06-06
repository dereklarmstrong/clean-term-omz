# clean-term zsh theme

A clean, minimal zsh theme for Oh My Zsh with a dashed separator, left-aligned directory, and right-aligned git branch.

## Preview

### Default prompt

```
────────────────────────────────────────────────────
  ~/code/my-project                    main
>
```

### Inside a git repo with changes

```
────────────────────────────────────────────────────
  ~/code/my-project/src            feat/add-auth
>
```

### Root user

```
────────────────────────────────────────────────────
  /etc/nginx
#
```

## Features

- **Dashed horizontal separator** — clean visual break between prompts
- **Current working directory** — left-aligned, bold white
- **Git branch** — right-aligned, green (only shown in git repos)
- **User indicator** — `>` for regular users, `#` for root
- **Zero bloat** — no custom characters, no color coding complexity, no prompt pollution

## Installation

### One-command install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dereklarmstrong/clean-term-omz/main/install.sh)"
```

This runs an interactive installer where you pick your plugins:

```
Plugins (optional — just my personal preferences)
The theme works fine without them. Pick any you want:

  1) zsh-autosuggestions
  2) zsh-syntax-highlighting
  3) zsh-history-substring-search

  [Enter] to skip all

  Plugin numbers (comma-separated, e.g. 1,2,3):
```

It installs:

- **Oh My Zsh** (if not already installed)
- **clean-term theme**
- **Plugins** — choose from:
  - `git` (built-in, always included)
  - `zsh-autosuggestions` — predictive suggestions
  - `zsh-syntax-highlighting` — syntax-aware highlighting
  - `zsh-history-substring-search` — arrow-key history search
- Configures your `.zshrc` automatically

### Manual install

```bash
# Clone the theme into Oh My Zsh themes directory
git clone https://github.com/dereklarmstrong/clean-term-omz.git ~/.oh-my-zsh/custom/themes/clean-term-omz

# Copy the theme file
cp ~/.oh-my-zsh/custom/themes/clean-term-omz/themes/clean-term.zsh-theme ~/.oh-my-zsh/themes/clean-term.zsh-theme
```

Then add to your `.zshrc`:
```bash
ZSH_THEME="clean-term"
```

Or use it standalone:
```bash
source ~/.oh-my-zsh/custom/themes/clean-term-omz/themes/clean-term.zsh-theme
```

Finally, restart your terminal:
```bash
source ~/.zshrc
```

## Requirements

- Oh My Zsh (or zsh with prompt_subst enabled)
- Git (for branch display)
- zsh

## License

MIT - [LICENSE](LICENSE)
