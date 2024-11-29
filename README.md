# Description
This repository can be used to setup my preferred development environment on macOS.

## How does it work?
- [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html) to setup dotfiles
- [Homebrew](https://brew.sh/) as the package manager
- [homebrew-autoupdate](https://github.com/DomT4/homebrew-autoupdate) to keep packages updated automatically
- [homebrew-file](https://homebrew-file.readthedocs.io/en/latest/) to keep Brewfile up to date automatically
- [Antidote](https://antidote.sh/) to manage zsh plugins
- A Launchd script to sync this repo once a day automatically

# Setup
Clone the repo, then cd into it and run:
```
chmod +x setup.sh
./setup.sh
```

# TODO
- Configure zsh
  - Antibody
  - Prompt
- Configure zed
- Set zed as default editor
- git config
- Auto github auth setup
- Auto sync
- Auto update antidote
- AI
  - Get key
  - Raycast
  - Zed
- Raycast
  - Configure
  - Sync?
