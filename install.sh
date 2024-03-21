#!/bin/bash

local_has() {
  type "$1" > /dev/null 2>&1
}

custom_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

check_dependencies() {
    local missing_packages=()

    # Check if curl or wget is installed
    if ! local_has "curl" | local_has "wget"; then
        missing_packages+=("curl or wget")
    fi

    # Check if git is installed
    if ! local_has "git"; then
        missing_packages+=("git")
    fi

    # Check if nvm is installed
    if ! local_has "nvm"; then
        missing_packages+=("nvm")
    fi

    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo "Error: The following packages are required for installation: ${missing_packages[*]}"
        exit 1
    fi
}

script_download() {
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

install_as_script() {
  local install_dir="$HOME/.eparts_cli"

  if [ -f "$install_dir/eparts" ]; then
    nvm_echo "=> eparts is already installed in $install_dir, trying to update the script"
  else
    nvm_echo "=> Downloading eparts as script to '$install_dir'"
  fi

  script_download https://example.com/eparts -o "$install_dir/eparts" || {
    echo >&2 "Failed to download '$install_dir/eparts'"
    return 1
  }
}

check_install_dir() {
  local install_dir="$HOME/.eparts_cli"

  if [ ! -d "$install_dir" ]; then
    mkdir -p "$install_dir" || { echo "Error: Failed to create directory $install_dir"; exit 1; }
  fi
}

install_cli() {
  local install_dir="$HOME/.eparts_cli"

  check_dependencies

  check_install_dir

  install_as_script

  # Set execution permissions (if necessary)
  chmod +x "$install_dir/eparts.sh"

  # Update user's shell profile to include CLI in PATH (optional)
  echo "export PATH=\"\$PATH:$install_dir\"" >> "$HOME/.bashrc"
  source "$HOME/.bashrc"  # Reload shell profile

  echo "Installation complete. You can now use 'eparts' command."
}