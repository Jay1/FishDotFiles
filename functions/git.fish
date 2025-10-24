function git
    if string match -q '/mnt/*' (pwd -P)
        git.exe $argv
    else
        command git $argv
    end
end
