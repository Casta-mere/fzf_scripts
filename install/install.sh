# Author Casta-mere

INSTALL_DIR="$HOME/.fzf-scripts"
BIN_SCRIPT="fzf-scripts.sh"
INSTALLER_SCRIPT="install.sh"
REPO="Casta-mere/fzf_scripts"
SCRIPT_URL="https://github.com/$REPO/releases/latest/download/$BIN_SCRIPT"
INSTALLER_URL="https://github.com/$REPO/releases/latest/download/$INSTALLER_SCRIPT"
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
  local tmp_script tmp_installer ver_current ver_latest updated=false
  tmp_script="$(mktemp)"
  tmp_installer="$(mktemp)"

  ver_current="$(grep '^# VERSION=' "$INSTALL_DIR/$BIN_SCRIPT" | cut -d= -f2)"
  curl -fsSL -o "$tmp_script" "$SCRIPT_URL"
  ver_latest="$(grep '^# VERSION=' "$tmp" | cut -d= -f2)"

  if [[ "$ver_latest" > "$ver_current" ]]; then
    echo "Updating $BIN_SCRIPT: $ver_current → $ver_latest"
    mv "$tmp_script" "$INSTALL_DIR/$BIN_SCRIPT"
    chmod +x "$INSTALL_DIR/$BIN_SCRIPT"
    echo "Also updating $INSTALLER_SCRIPT"
    mv "$tmp_installer" "./$INSTALLER_SCRIPT"
    chmod +x "./$INSTALLER_SCRIPT"
    updated=true
  else
     rm "$tmp_script" "$tmp_installer"
    echo "Already at latest version ($ver_current)"
  fi

  if [[ "$updated" = true ]]; then
    exec "$INSTALL_DIR/$BIN_SCRIPT" --no-update "${@:2}"
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
    echo -e "Usage: install.sh  \n --install \n --update \n --uninstall \n --version"
    ;;
esac