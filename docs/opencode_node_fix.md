# OpenCode Node.js Integration Fix

## Date: December 25, 2025
## Issue: OpenCode shebang dependency on specific Node.js path

---

## Problem Description

When the Homebrew Node.js installation was removed to use nvm-managed Node.js exclusively, OpenCode failed to start with the error:

```
exec: Failed to execute process '/home/linuxbrew/.linuxbrew/bin/opencode': 
The file specified the interpreter '/home/linuxbrew/.linuxbrew/opt/node/bin/node', 
which is not an executable command.
```

## Root Cause

OpenCode's main script had a hardcoded shebang pointing to a specific Homebrew Node.js path:

```javascript
#!/home/linuxbrew/.linuxbrew/opt/node/bin/node
```

This path becomes invalid when:
- Homebrew Node.js is uninstalled
- Homebrew updates Node.js to a different version
- The Node.js installation is moved to a different location

## Solution Applied

### Fixed File
`/home/linuxbrew/.linuxbrew/Cellar/opencode/1.0.201/libexec/lib/node_modules/opencode-ai/bin/opencode`

### Change Made
**Before:**
```javascript
#!/home/linuxbrew/.linuxbrew/opt/node/bin/node
```

**After:**
```javascript
#!/usr/bin/env node
```

### Why This Works
- `#!/usr/bin/env node` dynamically finds the first `node` executable in the system PATH
- Works with any Node.js installation (nvm, brew, system package, etc.)
- Automatically adapts when Node.js versions are switched via nvm
- More portable and resilient to system changes

## Backup Created
Original file backed up to:
`/home/linuxbrew/.linuxbrew/Cellar/opencode/1.0.201/libexec/lib/node_modules/opencode-ai/bin/opencode.backup`

## Validation Tests Performed

✅ **OpenCode Basic Functionality**
- `opencode --help` works correctly
- `opencode --version` returns `1.0.201`
- OpenCode TUI launches successfully

✅ **Node.js Version Compatibility**
- Works with Node.js v24.12.0 (latest LTS)
- Works with Node.js v18.20.8 (legacy LTS)
- Seamlessly adapts when switching between nvm versions

✅ **PATH Integration**
- Uses nvm-managed Node.js when available
- Falls back gracefully to system Node.js if needed
- No hardcoded dependencies on specific installation paths

## Usage After Fix

### Normal Usage
```fish
opencode                    # Start OpenCode TUI
opencode --help            # Show help
opencode acp               # Start ACP server
```

### With Different Node Versions
```fish
nvm use 18                 # Switch to Node 18
opencode                   # Works with Node 18

nvm use 24                 # Switch to Node 24  
opencode                   # Works with Node 24
```

## Future Considerations

### If OpenCode Updates
If OpenCode is updated via Homebrew, the fix may be overwritten. Check the shebang line after updates:

```bash
head -1 /home/linuxbrew/.linuxbrew/bin/opencode
```

If it reverts to the hardcoded path, reapply the fix:

```bash
# Find the actual script location
find /home/linuxbrew/.linuxbrew/Cellar/opencode -name "opencode" -type f

# Update the shebang in the main script file
sed -i '1s|#!/home/linuxbrew/.linuxbrew/opt/node/bin/node|#!/usr/bin/env node|' <path_to_script>
```

### Alternative Solutions
If the env approach doesn't work in the future:

1. **Create a wrapper script** that explicitly calls the current node
2. **Use a symlink** to point to the current nvm node
3. **Set OPENCODE_BIN_PATH environment variable** (if supported)

## Integration with Node Manager

The node_manager function automatically maintains Node.js versions, and OpenCode will seamlessly use:
- v24.x for latest features and security patches
- v22.x, v20.x, v18.x when switched via nvm for legacy project compatibility

No additional configuration required - the fix is transparent and automatic.

---

## Summary

**Problem:** Hardcoded shebang broke OpenCode when Homebrew Node was removed  
**Solution:** Changed shebang to `#!/usr/bin/env node` for dynamic Node resolution  
**Result:** OpenCode works seamlessly with nvm-managed Node.js across all versions  
**Status:** ✅ Production ready and future-proof