# Quick Setup: 1Password GPG Integration

## Step 1: Store GPG Passphrase in 1Password

1. Open 1Password
2. Create a new "Password" item:
   - **Title**: `Github MoshPitCodes GPG Signing Key 2025-12-03`
   - **Vault**: `Private`
   - **Add a field**: Type `passphrase`, enter your GPG key passphrase

## Step 2: Enable Integration in NixOS

Edit `modules/home/default.wsl.nix` and add the import:

```nix
imports = [
  # ... existing imports ...
  ./gpg-1password.nix  # Add this line
];
```

Then add configuration (you can add this at the end of the file):

```nix
# Enable 1Password GPG integration
programs.gpg.onepassword = {
  enable = true;
};
```

## Step 3: Rebuild and Sign In

```bash
# Rebuild system
sudo nixos-rebuild switch --flake .#wsl

# Sign in to 1Password (do this ONCE per boot)
op signin

# Test GPG signing
echo "test" | gpg --clearsign
```

That's it! Now GPG will automatically retrieve your passphrase from 1Password.

## Customization

If you used different names in 1Password:

```nix
programs.gpg.onepassword = {
  enable = true;
  vault = "YourVaultName";       # Default: "Private"
  itemName = "YourItemName";     # Default: "Github MoshPitCodes GPG Signing Key 2025-12-03"
  fieldName = "YourFieldName";   # Default: "passphrase"
};
```

## Troubleshooting

**"op CLI not found"** - Make sure you're signed in:
```bash
op signin
```

**"1Password retrieval failed"** - Check item name and vault:
```bash
op item get "Github MoshPitCodes GPG Signing Key 2025-12-03" --vault "Private" --fields "passphrase"
```

**Switch back to manual entry** - Set `enable = false` and rebuild.
