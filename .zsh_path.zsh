# PATH for every zsh. Sourced by .zshenv (all shells) and again by .zprofile (login
# shells): macOS /etc/zprofile runs path_helper AFTER ~/.zshenv and moves the system
# directories to the front, so login shells re-source this to restore the order.
#
# mise owns tool paths: `mise activate` in .zshrc for interactive shells, and the
# shim directory below for everything else (scripts, agent shells, Herdr command
# panes). The static export is mise's documented no-fork alternative to
# `mise activate --shims`. The remaining entries are the directories mise does not
# manage. `typeset -U` keeps only the first occurrence of each entry, which is what
# forces our order ahead of path_helper's.
typeset -U path PATH
path=(
  "$HOME/.local/share/mise/shims"   # mise-managed tools (non-interactive shells)
  "$HOME/.local/bin"                # mise itself
  /opt/homebrew/bin(N)              # Homebrew, macOS only; (N) drops the entry when absent
  "$HOME"/scripts/*(N-/)            # this repo's scripts, one directory per tool
  $path
)
export PATH
