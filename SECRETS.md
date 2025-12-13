# Secret Management Guide

This NixOS configuration uses environment variables for secure credential management, eliminating the need for hardcoded secrets in configuration files.

## Quick Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your actual values:**
   ```bash
   # Required for system configuration
   NIXOS_USERNAME=your-actual-username
   GIT_USERNAME=your-git-username
   GIT_EMAIL=your-email@example.com
   
   # Optional for WiFi (leave empty if using NetworkManager)
   WIFI_SSID=your-wifi-network
   WIFI_PASSWORD=your-wifi-password
   
   # Repository configuration (for customizing directory name)
   NIXOS_REPO_NAME=moshpitcodes.nix
   
   # Optional for development tools
   ANTHROPIC_API_KEY=your-claude-api-key
   OPENAI_API_KEY=your-openai-api-key
   ```

3. **Source the environment variables:**
   ```bash
   source .env
   ```

4. **Rebuild your NixOS configuration:**
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

## Security Features

- ✅ **No hardcoded secrets** - All sensitive data uses environment variables
- ✅ **Git protection** - `.env` and `secrets.nix` are automatically ignored
- ✅ **Template files** - `.env.example` and `secrets.nix.example` show required format
- ✅ **Doppler integration** - Existing support for professional secret management
- ✅ **Fallback support** - Environment variables take precedence over file-based secrets

## Usage Methods

### Method 1: Environment Variables (Recommended)
```bash
export NIXOS_USERNAME="your-username"
export GIT_USERNAME="your-git-username"
export GIT_EMAIL="your-email@example.com"
export NIXOS_REPO_NAME="your-repo-directory-name"
```

### Method 2: .env File
```bash
cp .env.example .env
# Edit .env with your values
source .env
```

### Method 3: Doppler (Professional)
```bash
doppler secrets set NIXOS_USERNAME=your-username
doppler secrets set GIT_USERNAME=your-git-username
doppler secrets set GIT_EMAIL=your-email@example.com
doppler secrets set NIXOS_REPO_NAME=your-repo-directory-name
doppler run -- sudo nixos-rebuild switch --flake .
```

### Method 4: secrets.nix File (Alternative)
```bash
cp secrets.nix.example secrets.nix
# Edit secrets.nix with your values
```

## Configuration Files Changed

- `flake.nix:39` - Username now uses `NIXOS_USERNAME` environment variable
- `modules/home/git.nix:6-7` - Git credentials use `GIT_USERNAME` and `GIT_EMAIL`
- `modules/core/network.nix:11-19` - WiFi credentials use `WIFI_SSID` and `WIFI_PASSWORD`
- `modules/home/zsh/zsh_alias.nix:35-38` - cdnix alias uses `NIXOS_REPO_NAME` environment variable

## Helper Functions

The `lib/secrets.nix` file provides utilities for advanced secret management:

```nix
# Import in your modules
{ lib, ... }:
let
  secrets = import ../lib/secrets.nix { inherit lib; };
in
{
  # Use helper functions
  programs.git.userName = secrets.credentials.getGitUserName;
  programs.git.userEmail = secrets.credentials.getGitUserEmail;
}
```

## Troubleshooting

**Problem:** Build fails with "value is an empty string"
**Solution:** Ensure all required environment variables are set:
```bash
echo $NIXOS_USERNAME
echo $GIT_USERNAME
echo $GIT_EMAIL
```

**Problem:** WiFi not configured
**Solution:** WiFi variables are optional. Use NetworkManager GUI or set `WIFI_SSID` and `WIFI_PASSWORD`.

**Problem:** API keys not working
**Solution:** API keys are optional. Only set them if you're using the respective development tools.

## Migration from throw statements

If you're upgrading from the old `throw` statement approach:

1. Your old configuration files have been automatically updated
2. No manual editing of `.nix` files is required
3. Just set the environment variables as shown above
4. The system will work exactly as before, but more securely

## Security Best Practices

- Never commit `.env` or `secrets.nix` files to version control
- Use different credentials for different environments (dev/staging/prod)
- Consider using Doppler or similar tools for team environments
- Regularly rotate API keys and passwords
- Use system keyring for additional security (GNOME Keyring is enabled)