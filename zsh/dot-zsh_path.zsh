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
# `brew shellenv` in .zshrc — the Homebrew prefix is detected below via cheap dir
# probes (no subprocess), so PATH works on macOS (/opt/homebrew) and linuxbrew
# (/home/linuxbrew/.linuxbrew) without depending on brew being on PATH yet.

# Detect the Homebrew prefix without a subprocess (brew isn't on PATH yet, and
# `brew --prefix` would fork). First prefix with an executable brew wins. Kept SET
# (not unset) so .zshrc can reuse it for `brew shellenv` in the same shell
# (.zshenv → .zshrc run in one process).
_brew_prefix=
for _p in /opt/homebrew /home/linuxbrew/.linuxbrew /usr/local; do
  if [[ -x "$_p/bin/brew" ]]; then _brew_prefix="$_p"; break; fi
done
_brew_bins=()
[[ -n "$_brew_prefix" ]] && _brew_bins=("$_brew_prefix/bin" "$_brew_prefix/sbin")

# Prepend our dirs ahead of the system dirs. `typeset -U` keeps only the first
# occurrence of each entry, so this both de-dupes and forces our dirs to the front —
# undoing path_helper's reorder when sourced from .zprofile. Brew's bin/sbin sit after
# fnm's dir (so fnm-managed Node wins) via the $_brew_bins array, which expands to
# nothing when no brew is found. (An array is used because zsh's ${x:+a b} would yield
# a single joined word, not two elements.)
typeset -U path PATH
path=(
  "$HOME/.local/share/fnm/aliases/default/bin"   # fnm's default Node (follows `fnm default`)
  $_brew_bins                                    # Homebrew bin+sbin (prefix detected above)
  "$HOME/.local/bin"
  "$HOME/scripts"
  "$HOME"/scripts/*(N-/)
  $path
)
unset _p _brew_bins
export PATH
