# .zshenv
#
# Shared PATH discovery, history management, etc. across all machines.
# .zshrc.local is reserved for per-machine customization.

### PATH ###

pathappend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

pathappend \
    "$HOME/.local/bin" \
    "$HOME/.pyenv/bin" \
    "/usr/sbin" \
    "/usr/local/go/bin" \
    "$HOME/.config/emacs/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/go/bin"

if [ -d "$HOME/.pyenv/bin" ]; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

if [ -d "$HOME/.bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    [ -s "/home/josh/.bun/_bun" ] && source "/home/josh/.bun/_bun"
fi

bindkey '^ ' autosuggest-accept


### History ###

export HISTFILE=~/.histfile

# Ignore duplicates in history
setopt HIST_IGNORE_DUPS

# Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_ALL_DUPS
