#!/usr/bin/env sh
# New-machine entry point (macOS or a Coder Linux box). `coder dotfiles <repo>`
# runs the first of install.sh, install, bootstrap.sh, ... that it finds, so this
# name is what Coder's dotfiles module picks up. Everything else is declared in
# mise.toml; this only gets mise onto the machine and applies that config.
set -eu
cd "$(dirname "$0")"

# Always our own mise: the one a Coder box ships (apt, /usr/bin/mise) is too old
# to parse mise.toml.
if [ ! -x "$HOME/.local/bin/mise" ]; then
  curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"

mise trust
mise bootstrap --yes

# Coder accounts start on bash and have no password, so mise's own login-shell
# setting (a plain chsh) fails there. mise installs zsh above.
if [ "$(uname -s)" = Linux ]; then
  sudo chsh -s /bin/zsh "$(id -un)"
fi
