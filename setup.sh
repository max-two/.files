# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Put brew on PATH for the rest of this script. A fresh Apple Silicon install
# does NOT add /opt/homebrew/bin to the current shell's PATH, so the brew calls
# below would fail with command-not-found without this.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install stow and brewfile
brew install stow
brew install rcmdnk/file/brew-file

# Setup dotfiles
stow brewfile
stow zsh
stow p10k
stow git
stow battery
stow claude
stow ghostty
stow helix
stow linear
stow navi
stow notes
stow opencode
# --no-folding: revdiff writes bundled themes into ~/.config/revdiff at runtime, so keep it a real dir (not a folded symlink into the repo)
stow --no-folding revdiff
stow storybook
stow worktrunk
stow yazi
stow zellij

# Install the rest of the packages
brew file install

# Install latest LTS Node with Corepack and make it the default for non-interactive shells
fnm install --lts --corepack-enabled
fnm default lts-latest
corepack install -g pnpm@latest

# Setup touch id sudo
sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local
