#!/usr/bin/env sh
# New-machine entry point (macOS or a Coder Linux box). `coder dotfiles <repo>`
# runs the first of install.sh, install, bootstrap.sh, ... that it finds, so this
# name is what Coder's dotfiles module picks up. Everything else is declared in
# mise.toml; this only gets mise onto the machine and applies that config.
set -eu
cd "$(dirname "$0")"

if [ ! -x "$HOME/.local/bin/mise" ] && ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"

mise trust
mise bootstrap --yes
