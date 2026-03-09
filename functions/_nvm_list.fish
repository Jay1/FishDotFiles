function _nvm_list
    set --local versions

    for path in $nvm_data/v*
        if test -d $path
            set versions $versions (basename $path)
        end
    end

    if test (count $versions) -gt 0
        printf '%s\n' $versions | sort -V
    end

    command --all node |
        string match --quiet --invert --regex -- "^$nvm_data" && echo system
end
