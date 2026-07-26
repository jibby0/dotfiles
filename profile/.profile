# ~/.profile: executed by the command interpreter for login shells.

alias ls='ls --color=auto'

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
