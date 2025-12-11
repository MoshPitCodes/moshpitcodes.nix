#!/usr/bin/env bash
# SAMBA/CIFS Mount Diagnostic Script for UGREEN NAS
# This script helps diagnose SMB mount issues and find correct share names

set -euo pipefail

NAS_IP="192.168.178.144"
NAS_HOSTNAME="DH2300-5EDE"
CREDS_FILE="/root/.secrets/samba-credentials"

echo "================================"
echo "UGREEN NAS SMB Mount Diagnostics"
echo "================================"
echo

# Function to run command with nix-shell
run_samba_cmd() {
    nix-shell -p samba --run "$1" 2>&1
}

# 1. Check network connectivity
echo "[1/7] Testing network connectivity to NAS..."
if ping -c 2 "$NAS_IP" &>/dev/null; then
    echo "✓ NAS is reachable at $NAS_IP"
else
    echo "✗ Cannot reach NAS at $NAS_IP"
    exit 1
fi
echo

# 2. Check SMB ports
echo "[2/7] Checking SMB ports (139, 445)..."
if command -v nc &>/dev/null; then
    if nc -zv "$NAS_IP" 445 2>&1 | grep -q succeeded; then
        echo "✓ Port 445 (SMB) is open"
    else
        echo "✗ Port 445 (SMB) is not accessible"
    fi
else
    echo "⚠ netcat not available, skipping port check"
fi
echo

# 3. Check credentials file
echo "[3/7] Checking credentials file..."
if [[ -f "$CREDS_FILE" ]]; then
    echo "✓ Credentials file exists at $CREDS_FILE"
    echo "  Permissions: $(stat -c %a $CREDS_FILE)"
    echo "  Contents (sanitized):"
    if [[ $EUID -eq 0 ]]; then
        sed 's/password=.*/password=***REDACTED***/g' "$CREDS_FILE" | sed 's/^/    /'
    else
        echo "    (Run as root to view credentials)"
    fi
else
    echo "✗ Credentials file not found at $CREDS_FILE"
    echo "  Run: sudo nixos-rebuild switch"
    exit 1
fi
echo

# 4. Extract credentials for testing
if [[ $EUID -eq 0 ]]; then
    USERNAME=$(grep '^username=' "$CREDS_FILE" | cut -d'=' -f2)
    DOMAIN=$(grep '^domain=' "$CREDS_FILE" | cut -d'=' -f2)
    PASSWORD=$(grep '^password=' "$CREDS_FILE" | cut -d'=' -f2)

    if [[ -n "$DOMAIN" ]]; then
        FULL_USER="${DOMAIN}\\${USERNAME}"
    else
        FULL_USER="$USERNAME"
    fi

    echo "[4/7] Testing authentication with extracted credentials..."
    echo "  Username: $USERNAME"
    echo "  Domain: ${DOMAIN:-<none>}"
    echo

    # 5. Try to list shares
    echo "[5/7] Attempting to list available shares..."
    echo "  Command: smbclient -L //$NAS_IP -U '$FULL_USER'"
    echo

    if run_samba_cmd "smbclient -L //$NAS_IP -U '${FULL_USER}%${PASSWORD}'"; then
        echo
        echo "✓ Successfully authenticated and listed shares"
    else
        echo
        echo "✗ Failed to authenticate or list shares"
        echo
        echo "Troubleshooting suggestions:"
        echo "  1. Check if username/password are correct in secrets.nix"
        echo "  2. Verify the domain/workgroup name (WORKGROUP vs NAS hostname)"
        echo "  3. Check NAS user permissions in UGREEN web UI"
        echo "  4. Try different authentication formats:"
        echo "     - username only (no domain)"
        echo "     - WORKGROUP\\username"
        echo "     - ${NAS_HOSTNAME}\\username"
    fi
    echo

    # 6. Try to connect to a specific share
    echo "[6/7] Testing connection to 'personal_folder' share..."
    echo "  Command: smbclient //$NAS_IP/personal_folder -U '$FULL_USER'"
    echo

    if run_samba_cmd "smbclient //$NAS_IP/personal_folder -U '${FULL_USER}%${PASSWORD}' -c 'ls'"; then
        echo
        echo "✓ Successfully connected to personal_folder share"
    else
        echo
        echo "✗ Failed to connect to personal_folder share"
        echo "  The share name might be incorrect. Check available shares above."
    fi
    echo

    # 7. Test mount manually
    echo "[7/7] Testing manual mount..."
    MOUNT_POINT="/tmp/ugreen-test-$$"
    mkdir -p "$MOUNT_POINT"

    echo "  Creating test mount at $MOUNT_POINT"
    if mount -t cifs "//$NAS_IP/personal_folder" "$MOUNT_POINT" \
        -o "credentials=$CREDS_FILE,vers=3.0,sec=ntlmssp,uid=1000,gid=100"; then
        echo "✓ Successfully mounted share manually"
        echo "  Contents:"
        ls -lah "$MOUNT_POINT" | head -10 | sed 's/^/    /'
        umount "$MOUNT_POINT"
        rmdir "$MOUNT_POINT"
    else
        echo "✗ Failed to mount share manually"
        echo "  Check dmesg for detailed error messages:"
        echo "  sudo dmesg | grep -i cifs | tail -10"
        rmdir "$MOUNT_POINT"
    fi
else
    echo "[4-7] Skipping authentication tests (requires root)"
    echo "  Run this script as root: sudo bash $0"
fi
echo

echo "================================"
echo "Diagnostics complete!"
echo "================================"
echo
echo "If all tests passed, run: sudo systemctl restart mnt-ugreen\\\\x2dnas.mount"
echo "Check mount status: systemctl status mnt-ugreen\\\\x2dnas.mount"
echo "View mount logs: journalctl -u mnt-ugreen\\\\x2dnas.mount -f"
