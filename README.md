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

### One-command install (TUI)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dereklarmstrong/clean-term-omz/main/install.sh)"
```

This gives you an interactive checkbox TUI where you pick your plugins:

```
┌──────────────────────────────────────────────────┐
│  Select plugins to install (Space to toggle,     │
│  Enter to confirm):                              │
│                                                  │
│  [ ] 1 git                                       │
│  [x] 2 zsh-autosuggestions                       │
│  [x] 3 zsh-syntax-highlighting                   │
│  [ ] 4 zsh-history-substring-search              │
│  [ ] 5 zsh-copyfile                              │
│                                                  │
│                              <OK>  <Cancel>      │
└──────────────────────────────────────────────────┘
```

It installs:

- **Oh My Zsh** (if not already installed)
- **clean-term theme**
- **Plugins** — choose from:
  - `git` (built-in)
  - `zsh-autosuggestions` — predictive suggestions
  - `zsh-syntax-highlighting` — syntax-aware highlighting
  - `zsh-history-substring-search` — arrow-key history search
  - `zsh-copyfile` — cp preserves timestamps
  - `zsh-compreply` — advanced completion
- Configures your `.zshrc` automatically

### Manual install

```bash
# Clone the theme into Oh My Zsh custom themes
git clone https://github.com/dereklarmstrong/clean-term-omz.git ~/.oh-my-zsh/custom/themes/clean-term-omz
```

Then add to your `.zshrc`:
```bash
ZSH_THEME="clean-term"
```

Or use it standalone:
```bash
source ~/.oh-my-zsh/custom/themes/clean-term-omz/clean-term.zsh-theme
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
