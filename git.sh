unalias glog 2>/dev/null
glog() {
  git log --graph --color=always \
    --format="%C(yellow)%h%C(reset) %C(auto)%d%C(reset) %s  %C(cyan)%an%C(reset)  %C(dim)%ar%C(reset)" "$@" \
  | fzf --ansi --no-sort --reverse --tiebreak=index \
    --preview 'grep -oE "[a-f0-9]{7,}" <<< {} | head -1 | xargs -I% git show --stat --color %' \
    --preview-window 'right:40%:wrap:hidden' \
    --bind 'enter:execute(grep -oE "[a-f0-9]{7,}" <<< {} | head -1 | xargs -I% git show --color % | less -R)' \
    --bind 'ctrl-y:execute-silent(grep -oE "[a-f0-9]{7,}" <<< {} | head -1 | pbcopy)+abort' \
    --bind 'ctrl-p:toggle-preview' \
    --header $'enter: git show  ctrl-y: copy hash  ctrl-p: toggle preview'
}