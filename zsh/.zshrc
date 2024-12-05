# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prompt
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Instant Prompt (Needs to stay at top of this file)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# P10K
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Exports
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Homebrew
export HOMEBREW_NO_ANALYTICS=1 # Turn off analytics
export HOMEBREW_NO_ENV_HINTS=1 # Turn off hints

# Brewfile
export HOMEBREW_BREWFILE_LEAVES=1 # Exclude dependencies from brewfile
export HOMEBREW_BREWFILE_APPSTORE=0 # Exclude AppStore apps from brewfile

# Bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'" # Make man pages colorful

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Aliases
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
alias rc='source $HOME/.zshrc'
alias zshrc='zed $HOME/.zshrc'
alias g='git'
alias ls='eza --color --icons --all --group-directories-first'
alias ll='eza --long --header --time-style=relative --no-filesize  --tree --level=2 --color --icons --all --group-directories-first'
alias z='zed'
alias zi='zed $(fzf -m --preview="bat --color=always {}")' # Fuzzy open files in zed
alias cat='bat'
alias ...='popd'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain' # Colorful help

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Keybindings
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Peruse history with the context of what's already been typed
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ZSH Configuration
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# cd
setopt autocd # cd without typing cd
setopt auto_pushd # Put cd history onto stack
setopt pushd_ignore_dups # Ignore duplicates for cd stack

# History
HISTSIZE=9999
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Completions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case insensitive completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Color completions
zstyle ':completion:*:git-checkout:*' sort false # Disable sort when completing `git checkout`
zstyle ':completion:*' menu no # Lets fzf capture unambiguous prefix
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 -a --color=always $realpath' # Show fzf directory previews for cd
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 -a --color=always $realpath' # Show fzf directory previews for zoxide

# Brewfile
brew_completion=$(brew --prefix 2>/dev/null)/share/zsh/zsh-site-functions
if [ $? -eq 0 ] && [ -d "$brew_completion" ];then
  fpath=($brew_completion $fpath)
fi

# Initialize completions
autoload -Uz compinit && compinit


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Antidote
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Other
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Auto ls after changing directory
function chpwd() {
    ls
}

# Wrap homebrew with brewfile
if [ -f $(brew --prefix)/etc/brew-wrap ];then
  source $(brew --prefix)/etc/brew-wrap
fi

# Colored git diff with bat
diff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

# Enable fzf integration
eval "$(fzf --zsh)"

# Enable zoxide (overrides cd command)
eval "$(zoxide init --cmd cd zsh)"
