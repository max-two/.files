#!/usr/bin/env bash
# Bootstrap this dotfiles repo on macOS or the Coder Linux workspace.
#
# One shared trunk with OS detection (uname); only the steps that TRULY differ
# branch: (1) acquiring Homebrew, (2) the macOS-only stow packages, (3) the
# Brewfile cask filter on Linux, (4) macOS Touch ID sudo. Everything else — the
# package list, the installer, the Node steps — is shared. See CLAUDE.md.

OS="$(uname -s)"

# (1) Ensure Homebrew exists. macOS: install it. Linux: the Coder workspace ships
# linuxbrew (/home/linuxbrew/.linuxbrew), so require it rather than installing.
if ! command -v brew >/dev/null 2>&1; then
  if [[ "$OS" == "Darwin" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "linuxbrew not found — install it first (the Coder workspace ships it)." >&2
    exit 1
  fi
fi

# A fresh install doesn't put brew on the current shell's PATH; add it via whichever
# prefix exists (macOS /opt/homebrew, linuxbrew /home/linuxbrew/.linuxbrew) so the
# brew calls below resolve.
for p in /opt/homebrew /home/linuxbrew/.linuxbrew /usr/local; do
  [[ -x "$p/bin/brew" ]] && eval "$("$p/bin/brew" shellenv)" && break
done

# (2) Symlink the dotfiles. ONE package list; the macOS-only packages are the sole
# delta (ghostty is a Mac GUI app; linear's coding-tool integration is Mac-app-only).
brew install stow
packages=(brewfile zsh p10k git battery claude helix navi notes opencode
          revdiff storybook worktrunk yazi zellij clip)
[[ "$OS" == "Darwin" ]] && packages+=(ghostty linear)
for pkg in "${packages[@]}"; do
  # --no-folding: revdiff writes bundled themes into ~/.config/revdiff at runtime, so
  # keep it a real dir (not a folded symlink into the repo).
  if [[ "$pkg" == "revdiff" ]]; then
    stow --no-folding revdiff
  else
    stow "$pkg"
  fi
done

# (3) Install the toolchain. ONE installer (brew bundle, built into Homebrew); only the
# Brewfile CONTENT differs — Linux strips the cask / macOS-only lines, which error on
# linuxbrew (casks are unsupported; terminal-notifier is macOS-only).
brewfile="$HOME/.config/brewfile/Brewfile"
if [[ "$OS" == "Linux" ]]; then
  brewfile="$(mktemp)"
  grep -vE '^(cask |brew terminal-notifier|tap homebrew/cask)' \
    "$HOME/.config/brewfile/Brewfile" > "$brewfile"
fi
brew bundle --file="$brewfile"

# (4) Install latest LTS Node with Corepack and make it the default for non-interactive
# shells. Shared — harmless if Node is already present (e.g. on the Coder box).
fnm install --lts --corepack-enabled
fnm default lts-latest
corepack install -g pnpm@latest

# (5) macOS-only: Touch ID for sudo (no PAM Touch ID on Linux).
if [[ "$OS" == "Darwin" ]]; then
  sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local
fi
