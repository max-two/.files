# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install stow and brewfile
brew install stow
brew install rcmdnk/file/brew-file

# Setup dotfiles
stow brewfile
stow zsh
stow p10k
stow git
stow ghostty
stow helix
stow navi
stow opencode
stow worktrunk
stow zellij

# Install the rest of the packages
brew file install

# Install latest LTS Node with Corepack and make it the default for non-interactive shells
fnm install --lts --corepack-enabled
fnm default lts-latest

# Setup touch id sudo
sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local
