# Fish Shell Configuration Documentation

## Node.js Version Management

This directory contains documentation for the Node.js version management system implemented on December 25, 2025.

### Quick Links

- **[Implementation Summary](node_manager_implementation_summary.md)** - Complete overview of the system, usage instructions, and maintenance guide
- **[Implementation Tasks](node_manager_implementation_tasks.md)** - Detailed task list and completion status from the installation
- **[OpenCode Node.js Fix](opencode_node_fix.md)** - Fix for OpenCode shebang dependency issue
- **[Rollback Script](rollback_node_setup.fish)** - Emergency rollback script if you need to revert changes

### Quick Start

#### Check Installed Versions
```fish
nvm list
```

#### Switch Node Versions
```fish
nvm use 18    # For legacy projects
nvm use 20    # For older projects
nvm use 22    # For previous LTS
nvm use 24    # For latest LTS (default)
```

#### Check Current Version
```fish
node --version
nvm current
```

#### Force Update Check
```fish
node_manager
```

#### View Update Log
```fish
cat ~/.nvm_manager.log
```

### System Overview

**Installed Node.js Versions:**
- v24.x (Krypton LTS) - Default
- v22.x (Jod LTS)
- v20.x (Iron LTS)
- v18.x (Hydrogen LTS)

**Auto-Update Frequency:** Every 14 days

**Next Update:** Check `~/.nvm_manager.log` for scheduled date

### Emergency Rollback

If you need to revert to the previous setup:

```fish
~/.config/fish/docs/rollback_node_setup.fish
exec fish
```

### File Locations

**Active Configuration:**
- Main config: `~/.config/fish/config.fish`
- Node manager function: `~/.config/fish/functions/node_manager.fish`
- Activity log: `~/.nvm_manager.log`
- Check timestamp: `~/.nvm_manager_last_check`

**Backups:**
- Config backup: `~/.config/fish/config.fish.backup.20251225_103701`
- Function backup: `~/.config/fish/functions/lts_periodically.fish.backup.20251225_103702`

### Support

For detailed information about the implementation, error handling, and troubleshooting, see the [Implementation Summary](node_manager_implementation_summary.md).

For OpenCode integration issues, see the [OpenCode Node.js Fix](opencode_node_fix.md) documentation.

---

**Status:** ✅ Production Ready  
**Maintenance:** Fully automated  
**Last Updated:** December 25, 2025
