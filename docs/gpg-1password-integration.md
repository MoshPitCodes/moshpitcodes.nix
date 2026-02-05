# GPG + 1Password Integration for WSL

This configuration automatically retrieves your GPG signing key passphrase from 1Password, eliminating constant password prompts during Git commit signing.

## How It Works

- **Custom Pinentry**: A custom `pinentry-1password` script implements the Assuan protocol used by GnuPG
- **1Password CLI**: The script uses `op` CLI to retrieve your GPG passphrase from 1Password
- **Automatic Caching**: GPG agent caches the passphrase for 8 hours (configurable)

## Setup Instructions

### 1. Install 1Password and Sign In

```bash
# The 1Password CLI (_1password-cli) is already included in your WSL config
# After rebuilding, sign in to 1Password
op signin

# Or if you're already signed in elsewhere, use:
eval $(op signin)
```

### 2. Store Your GPG Passphrase in 1Password

1. Open 1Password app (on Windows)
2. Create a new item or edit an existing one:
   - **Title**: `Github MoshPitCodes GPG Signing Key 2025-12-03` (or your preferred name)
   - **Vault**: `Private` (or your preferred vault)
   - **Add a field**: Name it `passphrase` and enter your GPG key passphrase

### 3. Configure Environment Variables (Optional)

If you used different names, set these environment variables in your shell:

```bash
# Add to ~/.zshrc or ~/.bashrc
export OP_GPG_VAULT="YourVaultName"   # Default: "Private"
export OP_GPG_ITEM="YourItemName"      # Default: "Github MoshPitCodes GPG Signing Key 2025-12-03"
export OP_GPG_FIELD="YourFieldName"    # Default: "passphrase"
```

### 4. Rebuild Your NixOS Configuration

```bash
sudo nixos-rebuild switch --flake .#nixos-wsl
```

### 5. Restart GPG Agent

```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

### 6. Test It

```bash
# Make a test commit
echo "test" >> test.txt
git add test.txt
git commit -m "Test GPG signing with 1Password"
```

The first time you commit, 1Password may prompt you for biometric authentication (if enabled). After that, the passphrase will be cached for 8 hours.

## Troubleshooting

### Check if pinentry is configured correctly

```bash
gpgconf --list-components | grep pinentry
```

Should show the custom pinentry-1password script.

### Test 1Password CLI

```bash
op item get "Github MoshPitCodes GPG Signing Key 2025-12-03" --vault "Private" --fields "passphrase"
```

This should output your GPG passphrase if configured correctly.

### Check GPG agent logs

```bash
gpg-connect-agent 'getinfo pid' /bye
# Note the PID, then check logs
journalctl --user -u gpg-agent
```

### Manual passphrase entry (fallback)

If 1Password integration fails, you can temporarily use standard pinentry:

```bash
# Edit ~/.gnupg/gpg-agent.conf
# Comment out or remove the pinentry-program line
# Then restart gpg-agent
gpgconf --kill gpg-agent
```

## Cache Configuration

The passphrase cache settings are in `~/.gnupg/gpg-agent.conf`:

- **default-cache-ttl**: 28800 seconds (8 hours)
- **max-cache-ttl**: 86400 seconds (24 hours)

You can adjust these values by editing `modules/home/gpg.nix` and rebuilding.

## Security Considerations

- 1Password CLI requires authentication (biometric or master password)
- The passphrase is cached in memory by GPG agent, not written to disk
- Cache timeout ensures the passphrase isn't stored indefinitely
- 1Password's security model is maintained throughout the process

## Alternative: Use pinentry-curses

If you prefer manual passphrase entry in the terminal instead of 1Password integration:

1. Edit `modules/core/program.nix`
2. Change `pinentryPackage` to `pkgs.pinentry-curses`
3. Rebuild with `sudo nixos-rebuild switch`

This will prompt you in the terminal for your passphrase each time (with caching).
