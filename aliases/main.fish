# BREW & PACKAGE MANAGEMENT
# -----------------------------------------------------------------------------
alias b='brew'
alias bcl='brew cleanup --prune=all'
alias bi='brew install'
alias binfo='brew info'
alias brm='brew uninstall'
alias bs='brew search'
alias bup='brew update; and brew upgrade'
alias bserv='brew services list'

# CLIPBOARD & INTERACTION
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command "Get-Clipboard"'
alias pwdc="pwd | tee /dev/tty | clip.exe"

# CORE UTILITIES
alias bgrep='batgrep'
alias cat='bat'
alias cls='clear'
alias editalias='v ~/.config/fish/aliases/main.fish'
alias explorer='explorer.exe .'
alias ls="ls -lAh --color=auto"
function __windows_pwsh --description 'Resolve Windows PowerShell from WSL'
    for candidate in \
            "/mnt/c/Program Files/PowerShell/7-preview/pwsh.exe" \
            "/mnt/c/Program Files/PowerShell/7/pwsh.exe" \
            "/mnt/c/Users/Jay/AppData/Local/Microsoft/WindowsApps/pwsh.exe"
        if test -x "$candidate"
            echo "$candidate"
            return 0
        end
    end

    if type -q pwsh.exe
        echo pwsh.exe
        return 0
    end

    return 1
end

function pshell --wraps=pwsh.exe --description 'Open pwsh in C:/Users/Jay by default, or current path with pshell .'
    set -l pwsh_bin (__windows_pwsh)
    if test -z "$pwsh_bin"
        echo "No Windows PowerShell binary found."
        return 127
    end

    if test (count $argv) -eq 0
        command "$pwsh_bin" -NoExit -WorkingDirectory "C:\Users\Jay"
    else if test "$argv[1]" = "."
        set -l winpwd (command wslpath -w -- "$PWD")
        command "$pwsh_bin" -NoExit -WorkingDirectory "$winpwd"
    else
        command "$pwsh_bin" $argv
    end
end
alias r='ranger'
function refresh --description 'Reload Fish config and conf.d snippets'
    source ~/.config/fish/config.fish
    for file in (find ~/.config/fish/conf.d -maxdepth 1 -type f | sort)
        source $file
    end
end

# DIRECTORY MOVEMENT
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# NAVIGATION SHORTCUTS
alias config='cd ~/.config'
alias dl='cd /mnt/c/Users/Jay/Downloads'
alias fdot='cd ~/.config/fish/'
alias files='cd /mnt/c/Users/Jay/OneDrive/Main_Backup/Files/'
alias home='cd "/mnt/c/Users/Jay/OneDrive/Desktop"'
alias code='cd ~/code/'
alias wprojects='cd /mnt/c/Code/'
alias sitrep='cd ~/aet/SITREPS/current/'
alias startupfolder='cd "/mnt/c/Users/Jay/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"'
alias temp='cd "/mnt/c/Users/Jay/OneDrive/Desktop/temp/"'
alias vdot='cd ~/.config/nvim/'

# NETWORK & TAILSCALE
alias ts='tailscale status'
alias tsip='sudo tailscale ip -4'
alias tsup='sudo tailscale up --ssh --operator=jay --accept-dns=false'
alias oc911='__oc911'
alias ocmodel-switch='ocmodel-switcher'
alias ocmodel='ocmodel-switcher'

# SAFETY NETS
alias chmod='chmod -v'
alias chown='chown -v'
alias cp='cp -i'
alias ln='ln -i'
alias mv='mv -i'
alias rm='rm -I'

# TMUX MANAGEMENT
# Primary: Attach 'main', detach others, or create new with split
alias t="tmux -f $HOME/.config/tmux/tmux.conf attach -t main -d || tmux -f $HOME/.config/tmux/tmux.conf new-session -s main \; split-window -h"
alias tls="tmux ls"
alias treset="tmux kill-session -t main; and t"

# WEATHER & INFO
alias moon="curl -4 wttr.in/Moon"
alias weather="curl -4 wttr.in/Montreal"

# WSL INTEGRATION
alias winpath='wslpath -u'
alias wslpath='wslpath -w'
