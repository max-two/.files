# Cache eval output, invalidate when the binary changes
_cached_eval() {
  local name=$1; shift
  local cache=$HOME/.cache/zsh/$name
  local bin=$(whence -p $1)

  if [[ ! -f $cache || $bin -nt $cache ]]; then
    mkdir -p $HOME/.cache/zsh
    "$@" > $cache
  fi
  source $cache
}
