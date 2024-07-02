# Basic Git operations
alias ga="git add"
alias gai="git add -i"
alias gs="git status"
alias gl="git log"
alias gl1="git log -n 1"
alias gf="git fetch --all"
alias gpull="git pull"
alias gpush="git push"

# Checkout and switch
alias gc="git checkout"
alias gci="git checkout -p"
alias gw="git switch"

# Commit
alias gm="git commit -m"
alias gma="git commit -am"

# Rebase
alias gr="git rebase --rebase-merges"
alias gri="git rebase -i"
alias grc="git rebase --continue"
alias gra="git rebase --abort"

# Other Git operations
alias grs="git restore"
alias gpick="git cherry-pick"
alias gb="git bisect"
alias gprune="git fetch -p"

# Advanced Git operations
alias gtree="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold yellow)%d%C(reset) %C(white)%s%C(reset) %C(bold green)(%ar)%C(reset) %C(dim white)- %an%C(reset)' --all"
alias gclean="git branch --merged | egrep -v '(^\*|main|master|dev|build|next)' | xargs git branch -d"
alias gcleanremote="git branch -r --merged | egrep -v '(^\*|main|master|dev|build|next)' | sed 's/origin\///' | xargs -n 1 git push --delete origin"

# Quick commit and push
function gquick
    git add .
    read -l -P 'Enter commit message: ' commit_message
    git commit -m "$commit_message"
    git push
end
