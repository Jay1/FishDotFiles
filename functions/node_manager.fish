function node_manager --description "Manages Node.js versions automatically - installs/updates current + LTS versions every 14 days"
    # Configuration
    set -l check_file ~/.nvm_manager_last_check
    set -l check_interval_seconds 1209600  # 14 days
    set -l log_file ~/.nvm_manager.log
    
    # Target LTS major versions to maintain
    set -l target_versions 24 22 20 18
    
    # Check if nvm is available
    if not type -q nvm
        echo "⚠️  nvm not available, skipping Node.js version management" >&2
        return 1
    end
    
    # Get current timestamp
    set -l current_timestamp (date +%s)
    set -l last_check_timestamp 0
    
    # Read last check timestamp if it exists
    if test -f $check_file
        set -l file_content (string trim (cat $check_file 2>/dev/null))
        if string match -q --regex '^[0-9]+$' $file_content
            set last_check_timestamp $file_content
        end
    end
    
    # Calculate time since last check
    set -l time_since_last_check (math $current_timestamp - $last_check_timestamp)
    
    # Skip if not enough time has passed
    if test $time_since_last_check -lt $check_interval_seconds
        return 0
    end
    
    # Pre-flight: Check network connectivity
    if not ping -c 1 -W 2 nodejs.org >/dev/null 2>&1
        echo "⚠️  No network connectivity, skipping Node.js update" >&2
        return 1
    end
    
    echo "🔄 Node.js Manager: Checking for updates..." | tee -a $log_file
    echo "📅 Last check: "(date -d @$last_check_timestamp 2>/dev/null || echo "Never") | tee -a $log_file
    
    set -l updates_made 0
    set -l errors_occurred 0

    # Ensure latest current release is installed
    echo "📦 Processing Node.js latest (current)..." | tee -a $log_file
    set -l latest_current (nvm list-remote latest | string match -r 'v\d+\.\d+\.\d+')[1]

    if test -z "$latest_current"
        echo "  ⚠️  Could not find latest current release" | tee -a $log_file
        set errors_occurred (math $errors_occurred + 1)
    else
        set -l installed_versions (nvm list | string trim)

        if string match -q "*$latest_current*" "$installed_versions"
            echo "  ✓ Already have latest current: $latest_current" | tee -a $log_file
        else
            echo "  ⬇️  Installing latest current: $latest_current..." | tee -a $log_file
            if nvm install $latest_current >/dev/null 2>&1
                echo "  ✅ Successfully installed $latest_current" | tee -a $log_file
                set updates_made (math $updates_made + 1)
            else
                echo "  ❌ Failed to install $latest_current" | tee -a $log_file
                set errors_occurred (math $errors_occurred + 1)
            end
        end
    end
    
    # Install/update each target version
    for node_ver in $target_versions
        echo "📦 Processing Node.js $node_ver.x..." | tee -a $log_file
        
        # Get latest version in this major release
        set -l latest_remote (nvm list-remote | grep -E "v$node_ver\.[0-9]+\.[0-9]+" | tail -1 | string match -r 'v\d+\.\d+\.\d+' | head -1)
        
        if test -z "$latest_remote"
            echo "  ⚠️  Could not find latest v$node_ver.x release" | tee -a $log_file
            set errors_occurred (math $errors_occurred + 1)
            continue
        end
        
        # Check if this version is already installed
        set -l installed_versions (nvm list | grep "v$node_ver\." | string trim)
        
        if string match -q "*$latest_remote*" "$installed_versions"
            echo "  ✓ Already have latest: $latest_remote" | tee -a $log_file
        else
            echo "  ⬇️  Installing $latest_remote..." | tee -a $log_file
            if nvm install $latest_remote >/dev/null 2>&1
                echo "  ✅ Successfully installed $latest_remote" | tee -a $log_file
                set updates_made (math $updates_made + 1)
                
                # Clean up old patch versions in this major release
                for old_ver in (nvm list | grep "v$node_ver\." | grep -v "$latest_remote" | string trim)
                    set -l version_number (string replace -r '.*v' 'v' $old_ver | string trim)
                    if test -n "$version_number"
                        echo "  🗑️  Removing old patch version: $version_number" | tee -a $log_file
                        nvm uninstall $version_number >/dev/null 2>&1
                    end
                end
            else
                echo "  ❌ Failed to install $latest_remote" | tee -a $log_file
                set errors_occurred (math $errors_occurred + 1)
            end
        end
    end
    
    # Set default to newest installed version
    echo "🔧 Setting default to newest installed version..." | tee -a $log_file
    if set -l newest_installed (nvm list | string match -r 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)
        if test -n "$newest_installed"
            set -U nvm_default_version latest-installed
            nvm use $newest_installed >/dev/null 2>&1
            echo "✅ Default set to installed latest: $newest_installed" | tee -a $log_file
        else
            echo "⚠️  Could not determine newest installed Node version" | tee -a $log_file
        end
    else
        echo "⚠️  Could not determine newest installed Node version" | tee -a $log_file
    end
    
    # Update timestamp
    echo $current_timestamp > $check_file
    
    # Summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a $log_file
    if test $updates_made -gt 0
        echo "✨ Node.js Manager: Installed/updated $updates_made version(s)" | tee -a $log_file
    else
        echo "✓ Node.js Manager: All versions up to date" | tee -a $log_file
    end
    
    if test $errors_occurred -gt 0
        echo "⚠️  Encountered $errors_occurred error(s) - check $log_file for details" | tee -a $log_file
    end
    
    echo "📅 Next check: "(date -d @(math $current_timestamp + $check_interval_seconds) 2>/dev/null || echo "in 14 days") | tee -a $log_file
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a $log_file
    
    return 0
end
