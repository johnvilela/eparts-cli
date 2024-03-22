#!/bin/bash
[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"

INSTALL_DIR="$HOME/.eparts_cli"

function local_has() {
  type "$1" > /dev/null 2>&1
}

function custom_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

function check_dependencies() {
    local missing_packages=()

    # Check if curl or wget is installed
    if ! local_has "curl" || ! local_has "wget"; then
        missing_packages+=("curl or wget")
    fi

    # Check if git is installed
    if ! local_has "git"; then
        missing_packages+=("git")
    fi

    # Check if nvm is installed
    if ! local_has "nvm" > /dev/null 2>&1; then
        missing_packages+=("nvm")
    fi

    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo "Error: The following packages are required for installation: ${missing_packages[*]}"
        exit 1
    fi
}

function script_download() {
  if local_has "curl"; then
    curl --fail --compressed -q "$@"
  elif local_has "wget"; then
    # Emulate curl with wget
    ARGS=$(custom_echo "$@" | command sed -e 's/--progress-bar /--progress=bar /' \
                            -e 's/--compressed //' \
                            -e 's/--fail //' \
                            -e 's/-L //' \
                            -e 's/-I /--server-response /' \
                            -e 's/-s /-q /' \
                            -e 's/-sS /-nv /' \
                            -e 's/-o /-O /' \
                            -e 's/-C - /-c /')
    # shellcheck disable=SC2086
    eval wget $ARGS
  fi
}

function install_as_script() {
  custom_echo

  if [ -f "$INSTALL_DIR/eparts" ]; then
    custom_echo "=> eparts is already installed in '$INSTALL_DIR', trying to update the script"
  else
    custom_echo "=> Downloading eparts as script to '$INSTALL_DIR'"
  fi

  script_download https://raw.githubusercontent.com/johnvilela/eparts-cli/v0.0.5-alpha/eparts -o "$INSTALL_DIR/eparts" || {
    echo >&2 "Failed to download '$INSTALL_DIR/eparts'"
    return 1
  }
}

function check_install_dir() {
  if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR" || { echo "Error: Failed to create directory $INSTALL_DIR"; exit 1; }
  fi
}

function install_cli() {
  check_dependencies

  check_install_dir

  install_as_script

  # Set execution permissions (if necessary)
  chmod +x "$INSTALL_DIR/eparts"

  # Update user's shell profile to include CLI in PATH (optional)
  echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
  source "$HOME/.bashrc"  # Reload shell profile

  custom_echo "Installation complete. You can now use 'eparts' command."
}

install_cli