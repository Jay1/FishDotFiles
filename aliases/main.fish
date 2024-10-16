# Terminal Commands
alias pwdc="pwd | tee /dev/tty | clip.exe"
alias cls='clear'

# Directory movements
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Goto (adjust paths for your WSL setup)
alias download='cd /mnt/c/Users/JasonChiasson/Downloads'
alias temp='cd "/mnt/c/Users/JasonChiasson/OneDrive - AET Solutions Inc/Desktop/temp/"'
alias home='cd "/mnt/c/Users/JasonChiasson/OneDrive - AET Solutions Inc/Desktop"'
alias config='cd ~/.config'
alias fdot='cd ~/.config/fish/'
alias vdot='cd ~/.config/nvim/'

# List (using ls instead of gls)
alias ls="ls -lAh --color=auto"

# Weather
alias weather="curl -4 wttr.in/Montreal"
alias moon="curl -4 wttr.in/Moon"

# WSL-specific aliases
alias explorer='explorer.exe .'
alias cmd='cmd.exe'
alias powershell='powershell.exe'

# Clipboard interaction
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command "Get-Clipboard"'

# WSL / Windows path conversion
alias wslpath='wslpath -w'
alias winpath='wslpath -u'

# Quick edit for this file
alias editaliases='v ~/.config/fish/aliases/main.fish'
