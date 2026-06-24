fkill() {
  local pid
  pid=$(ps aux | fzf --accept-nth 2)
  if [ -n "$pid" ]; then
    kill -9 "$pid"
  fi 
}

_ff_ignore_dirs=(node_modules .git __pycache__ .venv venv dist build .next target .cache)

ffgrep() {
  local query="$*"
  local ans
  local cmd_height=$(awk "BEGIN { printf \"%d\", $(tput lines) * 0.8 - 6 }")
  local offset=$(awk "BEGIN { printf \"%d\", $cmd_height * 0.5 }")
  local exclude_args=()
  for d in "${_ff_ignore_dirs[@]}"; do
    exclude_args+=(--exclude-dir="$d")
  done

  ans=$(grep -rnI --color=always -E "${exclude_args[@]}" "$query" . 2>/dev/null | \
    fzf --ansi \
        --delimiter ':' \
        --height=80% --reverse \
        --preview='batcat --color=always --paging=never {1} --highlight-line={2} --wrap=character' \
        --preview-window=right:60%,wrap,+{2}-$offset \
        --bind 'ctrl-p:toggle-preview' \
    )

    if [[ -n "$ans" ]]; then
      echo $ans | head -n1 | awk -F: '{print $1":"$2}' | xargs code -g
    fi
}

ff() {
  local prune_args=()
  for d in "${_ff_ignore_dirs[@]}"; do
    prune_args+=(-not -path "*/$d/*")
  done
  find . -type f "${prune_args[@]}" 2>/dev/null |
    fzf --preview 'batcat --color=always --style=header,grid --line-range :100 {}' \
        --preview-window=right:60%:wrap \
        --bind 'ctrl-p:toggle-preview' \

}

h() {
  fc -ln -2000 | awk '!seen[$0]++' \
    | fzf --tac --no-sort --reverse \
          --bind 'tab:down,shift-tab:up'
}

h-widget() {
  local cmd
  cmd=$(h) || return
  BUFFER="$cmd"
  CURSOR=${#BUFFER}
  zle reset-prompt
}
if [[ -n $ZSH_VERSION ]]; then
  zle -N h-widget
  bindkey '^R' h-widget
fi