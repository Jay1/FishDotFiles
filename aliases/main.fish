# Terminal Commands
alias pwdc="pwd | tee /dev/tty | clip.exe"
alias cls='clear'
alias refresh='source ~/.config/fish/config.fish'
alias ls="ls -lAh --color=auto"
alias explorer='explorer.exe .'
alias editalias='v ~/.config/fish/aliases/main.fish'

# Directory movements
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Navigation
alias dl='cd /mnt/c/Users/Jay/Downloads'
alias temp='cd "/mnt/c/Users/Jay/OneDrive/Desktop/temp/"'
alias home='cd "/mnt/c/Users/Jay/OneDrive/Desktop"'
alias startupfolder='cd "/mnt/c/Users/Jay/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"'
alias files='cd /mnt/c/Users/Jay/OneDrive/Main_Backup/Files/'
alias config='cd ~/.config'
alias fdot='cd ~/.config/fish/'
alias vdot='cd ~/.config/nvim/'

# Weather
alias weather="curl -4 wttr.in/Montreal"
alias moon="curl -4 wttr.in/Moon"

# Clipboard interaction
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command "Get-Clipboard"'

# WSL / Windows path conversion
alias wslpath='wslpath -w'
alias winpath='wslpath -u'
