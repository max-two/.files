# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Install stow and brewfile
brew install stow
brew install rcmdnk/file/brew-file

# Setup dotfiles
stow brewfile
stow zshrc

# Install the rest of the packages
brew file install
