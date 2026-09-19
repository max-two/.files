# Login shells only. macOS /etc/zprofile runs path_helper after ~/.zshenv and reorders
# PATH; re-sourcing the PATH file restores our order. Herdr starts login shells on
# macOS, so every pane passes through here.
source "${ZDOTDIR:-$HOME}/.zsh_path.zsh"
