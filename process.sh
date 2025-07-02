#!/bin/bash

fkill() {
  local pid
  pid=$(ps aux | fzf --accept-nth 2)
  if [ -n "$pid" ]; then
    kill -9 "$pid"
  fi 
}

ffgrep() {
  local query="$*"
  local ans
  local cmd_height=$(awk "BEGIN { printf \"%d\", $(tput lines) * 0.8 - 6 }") 
  local offset=$(awk "BEGIN { printf \"%d\", $cmd_height * 0.5 }")

  ans=$(grep -rnI --color=always -E "$query" . 2>/dev/null | \
    fzf --ansi \
        --delimiter ':' \
        --height=80% --reverse \
        --preview='batcat --color=always --paging=never {1} --highlight-line={2} --wrap=character' \
        --preview-window=right:60%,wrap,+{2}-$offset \
    )
    
    if [[ -n "$ans" ]]; then
      echo $ans | head -n1 | awk -F: '{print $1":"$2}'
    fi
}

ff() {
  local file
  file=$(find . -type f 2>/dev/null | fzf --height 80% --reverse --preview 'batcat --color=always {}' --preview-window=right:60%:wrap)
  if [ -n "$file" ]; then
    local absolute_path
    absolute_path=$(realpath "$file")
    echo "$absolute_path"
  else
    echo "No file selected."
  fi
}

ff() {
  find . -type f 2>/dev/null |
    fzf --preview 'batcat --color=always --style=header,grid --line-range :100 {}' \
        --preview-window=right:60%:wrap
}