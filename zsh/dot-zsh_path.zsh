# Single source of truth for PATH, sourced by BOTH:
#   - .zshenv   -> runs for EVERY zsh (incl. non-login / non-interactive: scripts,
#                  Zellij command panes, AI-agent shells) so they get the full PATH.
#   - .zprofile -> runs for LOGIN shells AFTER macOS /etc/zprofile's path_helper,
#                  which shoves system dirs to the front; re-sourcing here restores
#                  our order. The whole Zellij session inherits this from the login
#                  shell. See the comments in .zshenv / .zprofile for the full why.
#
# This file is PATH only (fast, no subprocess) so non-interactive shells stay cheap.
# The rest of the Homebrew env (HOMEBREW_*, INFOPATH, completions) is set by
# `brew shellenv` in .zshrc — /opt/homebrew/{bin,sbin} are hardcoded below so PATH
# doesn't depend on it.

# Prepend our dirs ahead of the system dirs. `typeset -U` keeps only the first
# occurrence of each entry, so this both de-dupes and forces our dirs to the front —
# undoing path_helper's reorder when sourced from .zprofile.
typeset -U path PATH
path=(
  "$HOME/.local/share/fnm/aliases/default/bin"   # fnm's default Node (follows `fnm default`)
  /opt/homebrew/bin
  /opt/homebrew/sbin
  "$HOME/.local/bin"
  "$HOME/scripts"
  "$HOME"/scripts/*(N-/)
  $path
)
export PATH
