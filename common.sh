#!/bin/bash

INSTALL_DIR="$HOME/.eparts_cli"

function local_has() {
  type "$1" > /dev/null 2>&1
}

function custom_echo() {
  command printf %s\\n "$*" 2>/dev/null
}