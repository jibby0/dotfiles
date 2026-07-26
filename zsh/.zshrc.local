bindkey '^ ' autosuggest-accept

# History

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Instantly write history
setopt -o sharehistory

# Ignore duplicates in history
setopt HIST_IGNORE_DUPS

# Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_ALL_DUPS

setopt appendhistory autocd extendedglob nomatch

# cdls
function cd {
    builtin cd "$@" && ls -F
}

