# Contributing to clean-term

First off, thanks for taking the time to contribute! This is a small solo project, so all contributions — even tiny ones — are appreciated.

## Quick Start

1. Fork the repo
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/clean-term-omz.git`
3. Create a branch: `git checkout -b feature/your-feature` or `fix/your-fix`
4. Make your changes
5. Commit with [conventional commit messages](#commit-message-conventions)
6. Push and open a [Pull Request](#pull-requests)

## Commit Message Conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/). Format:

```
<type>(<scope>): <description>

[optional body]
```

**Types:**

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Config, scripts, CI, maintenance |
| `docs` | Documentation changes |
| `style` | Formatting, whitespace, comments (no logic change) |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |

**Examples:**

```
feat(install): add plugin selection prompt
fix(theme): correct prompt symbol color
chore(ci): add syntax check job
docs(readme): update installation instructions
```

Keep the subject line under 72 characters. Use the imperative mood in the description ("add" not "added").

## Pull Requests

### Process

1. **Fork** the repository and create your branch from `main`
2. **Test** your changes — run `bash install.sh` locally if you modified the installer
3. **Open a PR** with a clear title and description
4. **GitHub Actions** will run automatically — all checks must pass before merging

### PR Requirements

- [ ] All GitHub Actions checks pass (see below)
- [ ] Changes are limited to a single focused scope
- [ ] Commit messages follow conventional commits
- [ ] No breaking changes to the installer behavior unless explicitly called out

### What the Checks Do

The workflow (`.github/workflows/install-tests.yml`) runs three jobs on every PR and push:

| Job | What it does |
|-----|-------------|
| **test-install** | Runs `install.sh` on Ubuntu 22.04, Ubuntu 24.04, macOS 14, and macOS 15. Verifies the theme file lands in the right place and `.zshrc` is configured correctly. |
| **syntax-check** | Runs `bash -n install.sh` to catch syntax errors in the installer. |
| **theme-check** | Verifies `themes/clean-term.zsh-theme` exists and passes `zsh -n` syntax validation. |

**All three jobs must pass** before a PR can be merged. If a check fails, fix the underlying issue and push again — the workflow re-runs automatically.

## Code Style

### Bash (`install.sh`)

- `set -euo pipefail` at the top (already enforced)
- Use `[[ ]]` for conditionals, not `[ ]`
- Quote all variable expansions: `"$var"`, not `$var`
- Use `command -v` to check for tools, not `which`
- Color codes defined at the top as named variables (`RED`, `GREEN`, etc.)
- Use the existing `info()`, `warn()`, `error()` helper functions for output
- Keep bash 3.x compatibility (macOS ships with bash 3.2)
- No subshell `$(...)` where a variable expansion suffices

### Zsh Theme (`themes/clean-term.zsh-theme`)

- Follow [Oh My Zsh theme conventions](https://ohmyz.sh/#theming)
- Use `%F{color}` for foreground colors, `%f` to reset
- Use `%(?.%F{green}.%F{red})` for conditional prompt symbols (exit status)
- Keep the prompt on a single line when possible
- Define all custom functions at the top, prompt rendering at the bottom
- No external command calls in prompt rendering (performance)
- Theme file is validated with `zsh -n` by CI

## Testing

There are no unit tests yet. Manual testing expectations:

- **Installer:** Run `bash install.sh` in a clean environment (or Docker container) and verify:
  - Oh My Zsh is installed if missing
  - Theme file lands at `$HOME/.oh-my-zsh/themes/clean-term.zsh-theme`
  - `.zshrc` has the correct `ZSH_THEME` and `plugins=` lines
  - Selected plugins are cloned to `$HOME/.oh-my-zsh/custom/plugins/`
- **Theme:** Source the theme in zsh and verify the prompt renders correctly
- **Cross-platform:** If you have access to both macOS and Linux, test on both

If you add automated tests, that's welcome — just add a `test-install` step or a new job to the workflow.

## Issues

When reporting issues, include:

- OS and version (e.g., "macOS 15.3", "Ubuntu 24.04")
- zsh version (`zsh --version`)
- What you ran and what happened vs. what you expected
- Any relevant output or error messages

Feature requests are welcome — describe what you want to achieve, not just what you want changed.

## License

By contributing, you agree that your contributions are licensed under the project's [LICENSE](./LICENSE).
