# Environment variable loader
# Source private env vars (gitignored)
if test -f $HOME/.config/fish/env/private.fish
    source $HOME/.config/fish/env/private.fish
end
