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

# Install the rest of the packages
brew file install

# Install lts node version
fnm install --lts

# Setup touch id sudo
sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local
