# Runs for every zsh, login or not, interactive or not. Keep it cheap: PATH only.
source "${ZDOTDIR:-$HOME}/.zsh_path.zsh"

# Machine-local environment (e.g. private registry tokens). Untracked on purpose.
[[ -f "$HOME/.localenv" ]] && source "$HOME/.localenv"
