#!/usr/bin/env bash
# Capture all monitors with grim, open in ksnip for annotation.
# ksnip on Hyprland only supports xdg-desktop-portal capture (no native area selection),
# so grim handles the capture and ksnip --edit handles annotation.

tmpfile=$(mktemp /tmp/screenshot-XXXXXX.png)
trap 'rm -f "$tmpfile"' EXIT

grim "$tmpfile"
ksnip --edit "$tmpfile"
