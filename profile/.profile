# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	      . "$HOME/.bashrc"
    fi
fi

alias ls='ls --color=auto'

# Custom ls colors
if command -v dircolors 2>&1 >/dev/null; then
    eval $(dircolors ~/.dircolors)
fi

pathappend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

pathappend \
    "$HOME/bin" \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.poetry/bin" \
    "$HOME/.pyenv/bin" \
    "/usr/local/go/bin" \
    "/usr/sbin" \
    "$HOME/go/bin"

if [ -d "$HOME/.pyenv/bin" ]; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src/"

if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

if command -v thefuck 2>&1 >/dev/null; then
    eval $(thefuck --alias)
fi

if [ -f "$HOME/.local/share/cloudflare-warp-certs/config.sh" ]; then
    source $HOME/.local/share/cloudflare-warp-certs/config.sh
fi
