# ~/.config/fish/functions/lts_periodically.fish

function lts_periodically
    # File to store the timestamp of the last check
    set -l last_check_file ~/.nvm_lts_last_check

    # Interval for checking: 14 days in seconds (14 * 24 * 60 * 60 = 1209600)
    set -l check_interval_seconds 1209600

    set -l current_timestamp (date +%s)
    set -l last_check_timestamp 0

    # Read the last check timestamp from the file if it exists and is valid
    if test -f $last_check_file
        set -l file_content (string trim (cat $last_check_file 2>/dev/null))
        if string match -q --regex '^[0-9]+$' $file_content
            set last_check_timestamp $file_content
        else
            set last_check_timestamp 0
        end
    end

    set -l time_since_last_check (math $current_timestamp - $last_check_timestamp)

    if test $time_since_last_check -ge $check_interval_seconds
        command nvm install 'lts/*' &>/dev/null
        echo $current_timestamp >$last_check_file
    end
end
