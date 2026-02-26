#!/usr/bin/env fish
# Rollback script for Node.js manager setup
# Run this if anything goes wrong during installation

echo "🔄 Rolling back to previous Node.js setup..."

# Find the most recent backup
set -l config_backup (ls -t ~/.config/fish/config.fish.backup.* 2>/dev/null | head -1)
set -l func_backup (ls -t ~/.config/fish/functions/lts_periodically.fish.backup.* 2>/dev/null | head -1)

if test -z "$config_backup"
    echo "❌ No config.fish backup found!"
    exit 1
end

echo "📋 Restoring config.fish from: $config_backup"
cp "$config_backup" ~/.config/fish/config.fish

if test -n "$func_backup"
    echo "📋 Restoring lts_periodically.fish from: $func_backup"
    cp "$func_backup" ~/.config/fish/functions/lts_periodically.fish
end

# Remove new node_manager function if it exists
if test -f ~/.config/fish/functions/node_manager.fish
    echo "🗑️  Removing new node_manager.fish"
    rm ~/.config/fish/functions/node_manager.fish
end

echo "✅ Rollback complete! Restart your shell with: exec fish"
