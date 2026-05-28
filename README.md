# clean-term zsh theme

A clean, minimal zsh theme for Oh My Zsh with a dashed separator, left-aligned directory, and right-aligned git branch.

## Preview

```
──────────────────────────────────────────────────────────────────────────────────
  ~/code/my-project                                       main
» 
```

## Features

- Dashed horizontal separator between prompts
- Current working directory on the left (bold white)
- Git branch name on the right (green) — only shown in git repos
- `»` prompt for regular users, `#` for root
- Ultimate simplicity — no bloat, no custom characters, no color coding complexity

## Installation

### Quick install (curl)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/dereklarmstrong/clean-term-omz/main/install.sh)"
```

### Manual install

```bash
git clone https://github.com/dereklarmstrong/clean-term-omz.git ~/.oh-my-zsh/custom/themes/clean-term-omz
```

Then add to your `.zshrc`:
```bash
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/themes/clean-term-omz"
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

## License

MIT — [LICENSE](LICENSE)
