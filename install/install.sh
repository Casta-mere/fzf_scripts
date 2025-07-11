# Author Casta-mere

INSTALL_DIR="$HOME/.fzf-scripts"
BIN_SCRIPT="fzf-scripts.sh"
INSTALLER_SCRIPT="install.sh"
REPO="Casta-mere/fzf_scripts"
SCRIPT_URL="https://github.com/$REPO/releases/latest/download/$BIN_SCRIPT"
shell_name="$(basename "$SHELL")"

case "$shell_name" in
  bash) rc="$HOME/.bashrc" ;;
  zsh)  rc="$HOME/.zshrc" ;;
  fish) rc="$HOME/.config/fish/config.fish" ;;
  *) echo "Unsupported shell: $shell_name"; exit 1 ;;
esac

download_script() {
  local target="$INSTALL_DIR/$BIN_SCRIPT"

  if [ -e "$target" ]; then
    echo "Found existing $target, skipping download."
  else
    echo "Downloading $BIN_SCRIPT..."
    curl -fsSL "$SCRIPT_URL" -o "$target"
  fi

  chmod +x "$target"
}

inject() {
  local rcfile="$1"; local src_line="$2"
  local start="# >>> fzf_script initialize >>>"
  local end="# <<< fzf_script initialize <<<"

  if grep -Fxq "$start" "$rcfile"; then
    echo "Already injected into $rcfile"
  else
    {
      echo ""
      echo "$start"
      echo "$src_line"
      echo 'alias  fzf_manage="~/.fzf-scripts/install.sh"'
      echo "$end"
      echo ""
    } >> "$rcfile"
    echo "Injected into $rcfile"
  fi
}

install() {
  echo "Installing fzf-scripts..."

  mkdir -p "$INSTALL_DIR"
  cp ./install.sh "$INSTALL_DIR/"

  download_script
  
  inject "$rc" "source \"$INSTALL_DIR/$BIN_SCRIPT\""
}

uninstall() {
  rm -rf "$INSTALL_DIR"
  echo "Removed install dir: $INSTALL_DIR"

  sed -i.bak '/# >>> fzf_script initialize >>>/,/# <<< fzf_script initialize <<</d' "$rc"
  echo "Cleaned from $rc"

  echo "Uninstall finished!"
}

update() {
  echo "Checking for updates..."
  local tmp file ver_current ver_latest
  ver_current="$(grep '^# VERSION=' "$INSTALL_DIR/$BIN_SCRIPT" | cut -d= -f2)"
  tmp="$(mktemp)"
  curl -fsSL "$SCRIPT_URL" -o "$tmp"
  ver_latest="$(grep '^# VERSION=' "$tmp" | cut -d= -f2)"

  if [[ "$ver_latest" > "$ver_current" ]]; then
    echo "Updating: $ver_current → $ver_latest"
    mv "$tmp" "$INSTALL_DIR/$BIN_SCRIPT"
    chmod +x "$INSTALL_DIR/$BIN_SCRIPT"
    exec "$INSTALL_DIR/$BIN_SCRIPT" --no-update "$@"
  else
    rm "$tmp"
    echo "Already up-to-date ($ver_current)"
  fi
}

version() {
  local ver_current 
  ver_current="$(grep '^# VERSION=' "$INSTALL_DIR/$BIN_SCRIPT" | cut -d= -f2)"
  echo "fzf-scripts $ver_current by Casta-mere"
}

case "$1" in
  --install) install ;;
  --update) update "${@:2}" ;;
  --uninstall) uninstall ;;
  --version) version ;;
  *)
    echo "Usage: install.sh --install | --update | --uninstall"
    ;;
esac