# Migration Guide: secrets.nix → config.nix + External Files

## Why Migrate?

**Current Problem (`secrets.nix`)**:
- Contains sensitive data (passwords, API keys)
- Easy to accidentally commit
- All secrets in one file
- No separation of concerns

**New Approach (`config.nix` + External Files)**:
- Configuration is public (safe to commit)
- Secrets stored externally on NAS
- Each secret type has its own file
- Clear separation of config vs secrets

## Architecture Comparison

### Before (secrets.nix)
```nix
{
  username = "moshpitcodes";
  hashedPassword = "$6$...hash...";           # ❌ In config
  git = { ... signingkey = "ABC123"; };
  
  samba = {
    password = "plaintext-password";          # ❌ Plaintext!
  };
  
  apiKeys = {
    anthropic = "sk-ant-api-key";             # ❌ In config
    openai = "sk-openai-key";                 # ❌ In config
  };
  
  sshKeys = { sourceDir = "/path"; keys = []; };
  gpgDir = "/path";
}
```

### After (config.nix + External)
```nix
# config.nix (safe to commit)
{
  username = "moshpitcodes";                  # ✅ Public
  git = { ... signingkey = "ABC123"; };       # ✅ Public key ID
  
  external = {
    secretsDir = "/mnt/ugreen-nas/.../secrets";
    userPasswordFile = ".../.secrets/user-password-hash";
    sambaCredentials = ".../.secrets/samba-credentials";
    envSecrets = ".../.secrets/env-secrets.sh";
    sshKeysDir = ".../.ssh";
    gpgDir = ".../.gnupg";
  };
}
```

```bash
# External files (never in Git)
/mnt/ugreen-nas/.../secrets/
├── user-password-hash      # $6$...hash...
├── samba-credentials       # username=...\npassword=...
└── env-secrets.sh          # export API_KEY="..."
```

## Migration Steps

### Step 1: Create config.nix

```bash
cd /home/moshpitcodes/Development/moshpitcodes.nix
cp config.nix.template config.nix  # We'll create this template
```

Edit `config.nix` with your **public** configuration:
```nix
{
  username = "moshpitcodes";
  reponame = "moshpitcodes.nix";
  
  git = {
    userName = "Mosh Pit";
    userEmail = "moshpitcodes@gmail.com";
    signingkey = "81322B518F331E00";
  };
  
  external = {
    secretsDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets";
    sshKeysDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.ssh";
    sshKeys = [ "id_ed25519_github" "id_ed25519_proxmox" ];
    gpgDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.gnupg";
    ghConfigDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.config/gh";
    sambaCredentials = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/samba-credentials";
    envSecrets = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh";
    userPasswordFile = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/user-password-hash";
  };
}
```

### Step 2: Move Secrets to External Files

```bash
# Extract user password hash from secrets.nix
grep hashedPassword secrets.nix | cut -d'"' -f2 > /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/user-password-hash
chmod 600 /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/user-password-hash

# Samba credentials (already done)
# Already at: /mnt/ugreen-nas/.../secrets/samba-credentials

# API keys (already done)
# Already at: /mnt/ugreen-nas/.../secrets/env-secrets.sh
```

### Step 3: Update Modules to Use config.nix

The following modules need updates:

**`modules/core/user.nix`** - Load password from external file:
```nix
{ customsecrets, lib, ... }:
let
  # Load password from external file if available
  hashedPassword = 
    if customsecrets ? hashedPassword then
      customsecrets.hashedPassword
    else if customsecrets ? external.userPasswordFile then
      let
        pwFile = customsecrets.external.userPasswordFile;
      in
      if builtins.pathExists pwFile then
        lib.strings.removeSuffix "\n" (builtins.readFile pwFile)
      else
        throw "Password file not found: ${pwFile}"
    else
      throw "No user password configured";
in
{
  users.users.${customsecrets.username} = {
    inherit hashedPassword;
    # ... rest of config
  };
}
```

**`modules/home/openssh.nix`** - Already uses `sshKeys.sourceDir` ✅

**`modules/home/gpg.nix`** - Already uses `gpgDir` ✅

**`modules/home/git.nix`** - Already uses `ghConfigDir` ✅

**`modules/core/samba.nix`** - Already uses `samba.credentialsFile` ✅

**`modules/home/secrets-loader.nix`** - Already uses external `envSecrets` ✅

### Step 4: Update Flake

Minimal changes needed. The flake currently looks for `secrets.nix`. We can make it look for `config.nix` first:

```nix
# In flake.nix, replace the secrets loading section:
customsecrets =
  if builtins.pathExists ./config.nix then
    import ./config.nix
  else if builtins.pathExists ./secrets.nix then
    import ./secrets.nix  # Backwards compatibility
  else
    defaultSecrets;
```

### Step 5: Test

```bash
# Rebuild with new config
sudo nixos-rebuild switch --flake .#wsl --impure

# Verify password still works
sudo -v

# Verify SSH keys loaded
ssh-add -l

# Verify GPG works
gpg --list-secret-keys

# Verify environment secrets loaded
echo $ANTHROPIC_API_KEY

# Verify Samba mounts
mount | grep ugreen
```

### Step 6: Remove secrets.nix

```bash
# Once everything works, remove the old file
git rm secrets.nix
# Or just delete it (it's git-ignored anyway)
rm secrets.nix

# Commit config.nix (it's safe now!)
git add config.nix
git commit -m "feat: migrate to config.nix with external secrets"
```

## Rollback Plan

If something goes wrong:

```bash
# 1. Restore secrets.nix from backup or Git
git checkout secrets.nix

# 2. Remove config.nix temporarily
mv config.nix config.nix.backup

# 3. Rebuild
sudo nixos-rebuild switch --flake .#wsl --impure

# 4. Debug the issue, then try again
```

## Benefits After Migration

| Aspect | Before | After |
|--------|---------|-------|
| **Config File** | Can't commit safely | ✅ Safe to commit |
| **Secrets Exposure** | All in one file | Separated by type |
| **Password Security** | In text file | Separate hash file |
| **API Keys** | In config | Environment variables |
| **Audit Trail** | Hidden in git-ignore | Config tracked in Git |
| **Team Sharing** | Share entire secrets | Share config only |

## Example: Using in CI/CD

With `config.nix`, you can:

1. **Commit config.nix** to Git
2. **Store secrets** in CI secrets manager
3. **Build in CI** with secrets injected

```yaml
# .github/workflows/build.yml
- name: Setup secrets
  run: |
    mkdir -p /tmp/secrets
    echo "${{ secrets.USER_PASSWORD_HASH }}" > /tmp/secrets/user-password-hash
    echo "${{ secrets.SAMBA_CREDENTIALS }}" > /tmp/secrets/samba-credentials

- name: Build
  run: nix build .#wsl --impure
```

## FAQ

**Q: Can I keep secrets.nix?**
A: Yes! The flake supports both. It will use `config.nix` if it exists, otherwise fall back to `secrets.nix`.

**Q: What if NAS is not mounted?**
A: The system will fail to build. This is intentional - better to fail than use wrong/stale secrets.

**Q: Can I use different paths per system?**
A: Yes! You can have `config.desktop.nix`, `config.wsl.nix`, etc. and symlink the active one to `config.nix`.

**Q: Is this more secure?**
A: Yes! Secrets are:
- Never in Git (even git-ignored)
- Separated by type
- Proper file permissions (600)
- Centralized on NAS

## Next Steps

1. **Create config.nix** with public configuration
2. **Move secrets** to external files on NAS
3. **Test thoroughly** before removing secrets.nix
4. **Commit config.nix** safely to Git
5. **Update documentation** to reference new system

---

**Ready to migrate?** Start with Step 1 above!
