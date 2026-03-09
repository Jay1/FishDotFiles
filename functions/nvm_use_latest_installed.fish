function nvm_use_latest_installed --description 'Activate the newest installed Node version via nvm'
    if not functions -q nvm
        return 1
    end

    set -l versions (_nvm_list | string match -r '^v[0-9]+\.[0-9]+\.[0-9]+$')
    if test (count $versions) -eq 0
        return 1
    end

    set -l latest (printf '%s\n' $versions | sort -V | tail -n 1)
    if test -z "$latest"
        return 1
    end

    nvm use --silent $latest >/dev/null
end
