# Terminal Commands
alias pwdc="command pwd | tee /dev/tty | pbcopy"

# Directory movements
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Goto
alias dl='cd ~/Downloads'
alias files='cd ~/Desktop/Files/'
alias fdot='cd ~/.config/fish/'
alias vdot='cd ~/.config/nvim/'
alias kdot='cd ~/.config/kitty/'
alias dotvault='cd ~/Dotvault/'

# List
alias ls="ls -fg"

# Weather
alias weather="curl -4 wttr.in/Montreal"
alias moon="curl -4 wttr.in/Moon"
alias et='sudo rm -rfv /Volumes/*/.Trashes; rm -rfv ~/.Trash'

#MacOS specific
alias update="sudo softwareupdate -i -a; brew update; brew upgrade"
alias flush="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias trash="rm -rf ~/.Trash/*"
