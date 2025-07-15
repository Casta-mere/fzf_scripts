# Author Casta-mere

INSTALL_DIR="$HOME/.fzf-scripts"
BIN_SCRIPT="fzf-scripts.sh"
INSTALLER_SCRIPT="install.sh"
INSTALLED="$INSTALL_DIR/$BIN_SCRIPT"
REPO="Casta-mere/fzf_scripts"
SCRIPT_URL="https://github.com/$REPO/releases/latest/download/$BIN_SCRIPT"
INSTALLER_URL="https://github.com/$REPO/releases/latest/download/$INSTALLER_SCRIPT"
shell_name="$(basename "$SHELL")"

case "$shell_name" in
  bash) rc="$HOME/.bashrc" ;;
  zsh)  rc="$HOME/.zshrc" ;;
  *) echo "Unsupported shell: $shell_name"; exit 1 ;;
esac

download_script() {
  echo "Downloading $BIN_SCRIPT..."
  curl  --connect-timeout 10 -fL "$SCRIPT_URL" -o "$INSTALLED" || { echo "download fail, Try manually download from https://github.com/Casta-mere/fzf_scripts/releases"; exit 1; }
  chmod +x "$INSTALLED"
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

check_install() {
  
  if [ -e "$INSTALLED" ]; then
    return 0
  else
    return 1
  fi
}

install() {
  if check_install; then
    echo -n "Already installed: "
    version
    return
  fi

  echo "Installing fzf-scripts..."

  mkdir -p "$INSTALL_DIR"

  if [ -e "$BIN_SCRIPT" ]; then
    echo "Found existing $BIN_SCRIPT in current directory, moving to $INSTALL_DIR."
    mv "$BIN_SCRIPT" "$INSTALLED"
  else
    download_script
  fi
  
  cp ./install.sh "$INSTALL_DIR/"
  
  inject "$rc" "source \"$INSTALLED\""
  echo -n "Successfully installed: "
  version
  echo "Reload your shell or 'source $rc' to activate"
}

uninstall() {
  if ! check_install; then
    echo "Not installed, nothing to uninstall"
    return 1
  fi

  rm -rf "$INSTALL_DIR"
  echo "Removed install dir: $INSTALL_DIR"

  sed -i.bak '/# >>> fzf_script initialize >>>/,/# <<< fzf_script initialize <<</d' "$rc"
  echo "Cleaned from $rc"

  echo "Uninstall finished!"
}

update() {
  if ! check_install; then
    echo "Not installed. Use \`./install.sh --install\` first"
    return 1
  fi

  echo "Checking for updates..."
  local tmp_script tmp_installer ver_current ver_latest updated=false
  tmp_script="$(mktemp)"
  tmp_installer="$(mktemp)"

  ver_current="$(grep '^# VERSION=' "$INSTALLED" | cut -d= -f2)"
  curl  --connect-timeout 10 -fL -o "$tmp_script" "$SCRIPT_URL" || { echo "download fail, Try manually download from https://github.com/Casta-mere/fzf_scripts/releases"; exit 1; }
  ver_latest="$(grep '^# VERSION=' "$tmp_script" | cut -d= -f2)"

  if { echo "$ver_current"; echo "$ver_latest"; } | sort -V -C; then
    echo "Updating $BIN_SCRIPT: $ver_current → $ver_latest"
    mv "$tmp_script" "$INSTALLED"
    chmod +x "$INSTALLED"
    echo "Also updating $INSTALLER_SCRIPT"
    curl  --connect-timeout 10 -fL -o "$tmp_installer" "$INSTALLER_URL" || { echo "download fail, Try manually download from https://github.com/Casta-mere/fzf_scripts/releases"; exit 1; }
    mv "$tmp_installer" "$INSTALL_DIR/$INSTALLER_SCRIPT"
    chmod +x "./$INSTALLER_SCRIPT"
    updated=true
  else
     rm "$tmp_script" "$tmp_installer"
    echo "Already at latest version ($ver_current)"
  fi

  if [[ "$updated" = true ]]; then
    exec "$INSTALLED" --no-update 
  fi
}

version() {
  if ! check_install; then
    echo "Not installed. Use \`./install.sh --install\` to install"
    return 1
  fi

  local ver_current
  ver_current="$(grep '^# VERSION=' "$INSTALLED" | cut -d= -f2)"
  echo "fzf-scripts $ver_current by Casta-mere"
}

case "$1" in
  --install) install ;;
  --update) update ;;
  --uninstall) uninstall ;;
  --version) version ;;
  *)
    echo -e "Usage: fzf_manage \n --install \n --update \n --uninstall \n --version"
    ;;
esac