# Language Server Configuration

This document explains the centralized Language Server Protocol (LSP) configuration in this NixOS setup.

## Overview

All language server tools, formatters, linters, and related development utilities are now consolidated in a single configuration file: `modules/home/language-servers.nix`.

This centralization provides:
- **Single source of truth** for enabled languages
- **Automatic synchronization** between editors (neovim, VSCode)
- **Easy maintenance** - enable/disable languages in one place
- **Clear organization** - all LSP packages grouped by language

## Architecture

```
modules/home/language-servers.nix
  ├── Language enablement flags
  ├── LSP package definitions (organized by language)
  ├── Session variables (for shell scripts)
  └── Module arguments (for other configs)
       ↓
       ├── modules/home/nvim.nix (uses lspLanguages)
       ├── modules/home/vscode.nix (uses lspLanguages)
       └── Other editors can access the same flags
```

## Enabled Languages

The following languages are currently enabled:

| Language | LSP Server | Formatter | Linter | Additional Tools |
|----------|-----------|-----------|--------|------------------|
| **C/C++** | clangd | clang-format | clang-tidy | cmake-ls |
| **CSS** | cssls | - | - | via vscode-langservers |
| **Go** | gopls | gofumpt | golangci-lint | delve (debugger) |
| **Java** | jdt-language-server | - | - | - |
| **JavaScript/TypeScript** | tsserver | prettierd | eslint | tailwindcss-ls |
| **Lua** | lua-ls | stylua | - | - |
| **Nix** | nixd, nil | nixfmt | statix | deadnix |
| **Python** | pyright | black, ruff | ruff | - |
| **Rust** | rust-analyzer | rustfmt | clippy | - |
| **Shell** | bashls | shfmt | shellcheck | - |
| **YAML** | yamlls | - | - | - |

### Disabled Languages

- **HTML** - Disabled due to superhtml build issues
- **Zig** - Disabled due to zls build issues

## How to Enable/Disable Languages

Edit `modules/home/language-servers.nix` and modify the `languages` attribute set:

```nix
languages = {
  c-cpp = true;               # Enabled
  css = true;
  go = true;
  html = false;               # Disabled
  java = true;
  javascript-typescript = true;
  lua = true;
  nix = true;
  python = true;
  rust = true;
  shell = true;
  yaml = true;
  zig = false;                # Disabled
};
```

After changing a flag:
1. The corresponding LSP packages will be installed/removed
2. Neovim will automatically enable/disable the language
3. VSCode language settings will be conditionally applied
4. Environment variables will reflect the change

Then rebuild your system:
```bash
sudo nixos-rebuild switch --flake .#vmware-guest
```

## Adding a New Language

To add support for a new language:

1. **Add to language enablement flags:**
   ```nix
   languages = {
     # ... existing languages ...
     kotlin = true;  # New language
   };
   ```

2. **Add LSP packages:**
   ```nix
   lspPackages = with pkgs;
     # ... existing packages ...
     ++ lib.optionals languages.kotlin [
       kotlin-language-server
       ktfmt  # Kotlin formatter
       ktlint # Kotlin linter
     ]
   ```

3. **Add session variable:**
   ```nix
   home.sessionVariables = {
     # ... existing variables ...
     LSP_KOTLIN_ENABLED = if languages.kotlin then "1" else "0";
   };
   ```

4. **Enable in neovim** (if nvf supports it):
   ```nix
   # In modules/home/nvim.nix
   languages = {
     # ... existing languages ...
     kotlin.enable = lspLanguages.kotlin;
   };
   ```

5. **Add VSCode settings** (optional):
   ```nix
   # In modules/home/vscode.nix
   // (
     if lspLanguages.kotlin then
       {
         kotlin.languageServer.enabled = true;
       }
     else
       { }
   )
   ```

## File Organization

### Before Consolidation
- LSP packages scattered across:
  - `modules/home/nvim.nix` (nixd, nixfmt)
  - `modules/home/development/development.nix` (gopls, rustfmt, clippy, etc.)
  - `modules/home/vscode.nix` (VSCode-specific settings)

### After Consolidation
- **`modules/home/language-servers.nix`** - All LSP packages and configuration
- **`modules/home/nvim.nix`** - Neovim editor config (references lspLanguages)
- **`modules/home/vscode.nix`** - VSCode editor config (references lspLanguages)
- **`modules/home/development/development.nix`** - Language runtimes only (gcc, go, nodejs, python3, etc.)

## Integration with Editors

### Neovim (nvf)

Neovim uses the [nvf](https://github.com/notashelf/nvf) framework. Language enablement is automatically synchronized:

```nix
languages = {
  clang.enable = lspLanguages.c-cpp;
  go.enable = lspLanguages.go;
  nix.enable = lspLanguages.nix;
  # ... etc
};
```

LSP features enabled in neovim:
- `formatOnSave = true` - Automatically format on save
- `lightbulb.enable = true` - Show code actions
- `trouble.enable = true` - Enhanced diagnostics UI
- `lspSignature.enable = true` - Function signature help

### VSCode

VSCode language server settings are conditionally applied based on `lspLanguages`:

```nix
userSettings = {
  # ... base settings ...
}
// (if lspLanguages.go then { go.useLanguageServer = true; } else {})
// (if lspLanguages.nix then { nix.enableLanguageServer = true; } else {})
```

## Environment Variables

The following environment variables are set for shell scripts and other tools:

```bash
LSP_C_CPP_ENABLED=1
LSP_CSS_ENABLED=1
LSP_GO_ENABLED=1
LSP_HTML_ENABLED=0  # Disabled
LSP_JAVA_ENABLED=1
LSP_JS_TS_ENABLED=1
LSP_LUA_ENABLED=1
LSP_NIX_ENABLED=1
LSP_PYTHON_ENABLED=1
LSP_RUST_ENABLED=1
LSP_SHELL_ENABLED=1
LSP_YAML_ENABLED=1
LSP_ZIG_ENABLED=0   # Disabled
```

You can check these in shell scripts:
```bash
if [ "$LSP_GO_ENABLED" = "1" ]; then
  # Go LSP is available
  gopls version
fi
```

## Troubleshooting

### Build issues with a language server

If a language server package fails to build:

1. **Disable the language temporarily:**
   ```nix
   languages = {
     problematic-lang = false;  # Disable temporarily
   };
   ```

2. **Rebuild the system:**
   ```bash
   sudo nixos-rebuild switch --flake .#vmware-guest
   ```

3. **Check nixpkgs for updates:**
   ```bash
   nix flake update
   ```

4. **Report the issue** and re-enable when fixed

### LSP not working in editor

1. **Verify language is enabled:**
   ```bash
   echo $LSP_<LANGUAGE>_ENABLED
   ```

2. **Check if LSP server is installed:**
   ```bash
   which gopls       # For Go
   which nixd        # For Nix
   which rust-analyzer  # For Rust
   ```

3. **Restart your editor** after rebuilding the system

4. **Check editor LSP logs:**
   - Neovim: `:LspInfo`, `:LspLog`
   - VSCode: Output panel → Select "Language Server" dropdown

### Package conflicts

If you see duplicate package warnings:

1. **Check `development.nix`** - ensure LSP tools aren't duplicated there
2. **Check `packages.nix`** - ensure no duplicate LSP packages
3. Language runtimes (compilers/interpreters) belong in `development.nix`
4. LSP servers, formatters, linters belong in `language-servers.nix`

## Best Practices

1. **Single source of truth** - Always enable/disable languages in `language-servers.nix`
2. **Keep runtimes separate** - Compilers/interpreters stay in `development.nix`
3. **Test after changes** - Always build test before committing:
   ```bash
   nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel
   ```
4. **Document additions** - Update this file when adding new languages
5. **Check for updates** - Language servers improve frequently, update with `nix flake update`

## Related Files

- `modules/home/language-servers.nix` - LSP configuration (this is the main file)
- `modules/home/nvim.nix` - Neovim editor configuration
- `modules/home/vscode.nix` - VSCode editor configuration
- `modules/home/development/development.nix` - Language runtimes and build tools
- `modules/home/default.nix` - Imports language-servers.nix

## Migration Notes

**Migrated from old configuration:**
- All LSP packages from `nvim.nix` → `language-servers.nix`
- All LSP packages from `development.nix` → `language-servers.nix`
- VSCode language settings now conditional on `lspLanguages`
- Neovim language enablement now synchronized with `lspLanguages`

**Preserved:**
- Language runtimes remain in `development.nix` (gcc, go, nodejs, python3, etc.)
- Build tools remain in `development.nix` (gradle, maven, etc.)
- Cloud/infrastructure tools remain in `development.nix` (kubectl, terraform, etc.)

---

**Last Updated:** 2026-02-15
**Maintained By:** moshpitcodes
