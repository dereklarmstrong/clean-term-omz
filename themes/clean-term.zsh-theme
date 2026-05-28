# Theme: clean-term
# Simple dashed separator, left dir, right branch.

setopt prompt_subst

_derek_dashes() {
  printf '%*s' "$COLUMNS" '' | tr ' ' '─'
}

PS1='%{$fg[237]%}$(_derek_dashes)%{$reset_color%}
  %{$fg_bold[white]%}%~%{$reset_color%} %{$fg[green]%}$(git branch --show-current 2>/dev/null || true)%{$reset_color%}
%(!.%{$fg_bold[red]%}#.%{$fg_bold[cyan]%}»)%{$reset_color%} '

PS2='%{$fg[yellow]%}>:::%{$reset_color%} '
