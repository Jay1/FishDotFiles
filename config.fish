if status is-interactive
    # Commands to run in interactive sessions can go here
end



contains /usr/local/bin $PATH
or set PATH /usr/local/bin $PATH
contains /opt/homebrew/bin
or set PATH /opt/homebrew/bin $PATH
contains /Users/jay/.local/bin
or set PATH /Users/jay/.local/bin $PATH

alias v='lvim'
set -gx EDITOR lvim
set -gx GIT_EDITOR $EDITOR

switch (uname)
case Linux
    set -x OSTYPE "Linux"
case Darwin
    set -x OSTYPE "MacOS"
case FreeBSD NetBSD DragonFly
    set -x OSTYPE "FreeBSD"
case '*'
    set -x OSTYPE "unknown"
end

if [ -f $HOME/.config/fish/env/index.fish ]
    source $HOME/.config/fish/env/index.fish
end

#
### ALIAS
#
# Main
if [ -f $HOME/.config/fish/aliases/main.fish ]
    source $HOME/.config/fish/aliases/main.fish
end

# Private aliases (e.g. with servers address...)
## aliases/private.fish will be ignored by git (.gitignore)
if [ -f $HOME/.config/fish/aliases/private.fish ]
    source $HOME/.config/fish/aliases/private.fish
end

# Git
if [ -f $HOME/.config/fish/aliases/git.fish ]
    source $HOME/.config/fish/aliases/git.fish
end