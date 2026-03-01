# TDD: Fix noto-fonts-subset build failure

**Task:** td-30c27e
**Author:** staff-engineer
**Status:** draft
**Date:** 2026-03-01

## Problem statement

`nixos-rebuild` fails for all three hosts (desktop, laptop, vmware-guest) because the LibreOffice derivation in nixpkgs generates a `noto-fonts-subset` intermediate derivation whose `buildCommand` contains a broken shell glob. The font file `NotoSansArabic[wdth,wght].ttf` uses OpenType variable-font axis notation with square brackets in the filename. The generated `cp` command quotes the path up to the `[`, leaving the remainder as an unquoted glob that expands to nothing inside the Nix sandbox, causing `cp` to fail with "missing destination file operand". This is a P1 blocker — no host can rebuild.

## Goals and non-goals

**Goals:**
- Restore successful `nix build` for all three host configurations
- Keep LibreOffice functional and installable
- Minimal, self-contained overlay that is easy to remove once nixpkgs fixes the upstream bug
- Pass `treefmt` and `nix flake check`

**Non-goals:**
- Fixing the upstream nixpkgs bug (that's a separate PR to nixpkgs)
- Changing which fonts are installed system-wide
- Modifying LibreOffice functionality or features

## Acceptance criteria

(From TD task)

1. `nix build .#nixosConfigurations.desktop.config.system.build.toplevel` succeeds
2. `nix build .#nixosConfigurations.laptop.config.system.build.toplevel` succeeds
3. `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
4. LibreOffice still installs and is functional
5. `treefmt` passes
6. `nix flake check` passes

## Proposed design

### Chosen approach: Option A — Override `libreoffice` to patch `noto-fonts-subset`

**Why Option A over the alternatives:**

| Option | Verdict | Reasoning |
|--------|---------|-----------|
| **A: Override libreoffice, patch buildCommand** | **Selected** | Directly fixes the root cause. The `noto-fonts-subset` derivation is an internal dependency of the LibreOffice build; overriding it to use `find`-based copying instead of a broken glob is surgical and correct. |
| B: Override `noto-fonts` to exclude variable fonts | Rejected | Removing variable fonts from the system-wide `noto-fonts` package is a lossy workaround. It degrades font coverage for all applications, not just LibreOffice. It also may not work — the `noto-fonts-subset` derivation references a specific store path of `noto-fonts`, so the override would need to propagate correctly through the LibreOffice dependency graph. |
| C: Switch to `libreoffice-still` | Rejected | No guarantee the stable branch avoids this bug (it uses the same `noto-fonts-subset` generation logic). Pins to an older LibreOffice version unnecessarily. Doesn't fix the root cause. |

### Overview

Create a new overlay file `overlays/libreoffice.nix` that overrides the `libreoffice` package. The override intercepts the `noto-fonts-subset` dependency and replaces its `buildCommand` with one that uses `find ... -exec cp` (or a properly escaped `cp` invocation) to handle filenames containing square brackets.

### Component changes

| Component | Change type | Notes |
|-----------|-------------|-------|
| `overlays/libreoffice.nix` | **add** | New overlay file containing the `libreoffice` override |
| `overlays/default.nix` | **modify** | Add import of `./libreoffice.nix` to the overlay list |

### Design detail: The Nix expression

The `noto-fonts-subset` derivation is not a top-level nixpkgs attribute — it's an internal derivation created inside the LibreOffice expression. The override strategy depends on how LibreOffice references it.

**Approach 1 (preferred): Override `libreoffice` via `overrideAttrs` to replace the `noto-fonts-subset` input**

The LibreOffice derivation in nixpkgs typically constructs `noto-fonts-subset` as a local derivation passed to the main build. The overlay should:

```nix
# overlays/libreoffice.nix — PSEUDOCODE / DESIGN SKETCH
{ inputs }:
final: prev:
let
  # Build a corrected noto-fonts-subset that uses find+cp
  # instead of the broken glob
  fixed-noto-fonts-subset = prev.runCommand "noto-fonts-subset" {
    noto = prev.noto-fonts;
  } ''
    mkdir -p "$out/share/fonts/noto/"
    find "$noto/share/fonts/noto" \
      -maxdepth 1 \
      -name '*.ttf' -o -name '*.otf' \
      | while read -r f; do
          cp "$f" "$out/share/fonts/noto/"
        done
  '';
in
{
  libreoffice = prev.libreoffice.override {
    # If libreoffice accepts noto-fonts-subset as an argument:
    noto-fonts-subset = fixed-noto-fonts-subset;
  };
}
```

**However**, the senior engineer MUST verify the actual override mechanism by inspecting the nixpkgs LibreOffice expression. The `noto-fonts-subset` may be:

1. **A parameter to the LibreOffice derivation** — use `.override { noto-fonts-subset = ...; }`
2. **Constructed inline via `runCommand` inside the derivation** — use `.overrideAttrs` to replace the reference, or override the `noto-fonts` input so the generated `buildCommand` doesn't encounter bracket filenames
3. **A separate derivation in `pkgs/applications/office/libreoffice/`** — override it directly if it's exposed

The senior engineer should run:
```bash
# Find how noto-fonts-subset is defined in nixpkgs
grep -r "noto-fonts-subset" $(nix eval nixpkgs#path --raw)/pkgs/
```

**Approach 2 (fallback): Override `noto-fonts` only within the LibreOffice scope**

If the `noto-fonts-subset` derivation cannot be cleanly overridden, an alternative is to override `noto-fonts` specifically for the LibreOffice build to rename or symlink files with brackets:

```nix
libreoffice = prev.libreoffice.override {
  noto-fonts = prev.noto-fonts.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      # Rename variable fonts to remove bracket notation
      for f in $out/share/fonts/noto/*\[*; do
        newname=$(echo "$f" | sed 's/\[.*\]//')
        mv "$f" "''${newname}.ttf"
      done
    '';
  });
};
```

This is less clean but avoids needing to understand the internal `noto-fonts-subset` construction.

### Where to put it

**New file: `overlays/libreoffice.nix`**

Rationale: The existing pattern is one overlay per concern (`td.nix`, `sidecar.nix`). A dedicated file keeps the fix isolated and easy to remove when nixpkgs merges an upstream fix.

### How to wire it

**Modify `overlays/default.nix`** to add the import:

```nix
{ inputs }:
[
  # Sidecar - TUI companion for AI coding workflows
  (import ./sidecar.nix { inherit inputs; })

  # TD - Task management for AI-assisted development
  (import ./td.nix { inherit inputs; })

  # LibreOffice - Fix noto-fonts-subset build failure (nixpkgs bug)
  (import ./libreoffice.nix { inherit inputs; })

  # Reposync - disabled (re-enable when needed)
  # (import ./reposync.nix { inherit inputs; })
]
```

**No changes to `flake.nix` are needed.** The flake already imports `./overlays` and applies the returned list as `nixpkgs.overlays` for all hosts (lines 126, 150, 189, 228). Adding a new entry to the list in `overlays/default.nix` is sufficient.

### Error handling

- If the overlay incorrectly overrides LibreOffice (e.g., wrong attribute name), `nix build` will fail with a clear Nix evaluation error — no silent breakage.
- If the `find`-based copy produces an empty font subset, LibreOffice will still build but may have missing font rendering for Noto glyphs. The senior engineer should verify the built `noto-fonts-subset` derivation contains the expected `.ttf`/`.otf` files.

### Security considerations

- No secrets, credentials, or network access involved.
- The overlay only modifies how font files are copied during the build — no change to runtime behavior or attack surface.
- The `find` command is scoped to a single known Nix store path; no risk of path traversal.

## Alternatives considered

| Alternative | Why rejected |
|-------------|-------------|
| **Pin nixpkgs to a commit before the bug** | Regresses all packages to an older snapshot. Unacceptable for a system on nixos-unstable. |
| **Remove LibreOffice entirely** | User needs LibreOffice (it's explicitly in `packages.nix`). |
| **Wait for upstream fix** | This is a P1 blocker — no host can rebuild. Cannot wait. |
| **Option B: Exclude variable fonts from `noto-fonts`** | Lossy — removes fonts system-wide. May not propagate correctly to the LibreOffice dependency. |
| **Option C: Switch to `libreoffice-still`** | No guarantee it avoids the bug. Unnecessary version downgrade. |

## Open questions

1. **How exactly is `noto-fonts-subset` constructed in the current nixpkgs LibreOffice expression?** The senior engineer must inspect the nixpkgs source to determine the correct override mechanism (`.override` vs `.overrideAttrs` vs direct derivation replacement). This is the critical implementation detail.

2. **Is there an upstream nixpkgs issue or PR for this bug?** If so, we may be able to cherry-pick the fix instead of writing our own overlay. The senior engineer should check `github.com/NixOS/nixpkgs/issues` for "noto-fonts-subset" or "NotoSansArabic".

3. **Should the overlay include a comment with a link to the upstream issue** so we remember to remove it when nixpkgs is fixed? (Recommendation: yes.)

## Implementation notes for Senior Engineer

### Step-by-step

1. **Inspect nixpkgs source** to understand how `noto-fonts-subset` is built:
   ```bash
   grep -r "noto-fonts-subset" $(nix eval nixpkgs#path --raw)/pkgs/
   ```
   Determine whether it's a parameter, an inline `runCommand`, or a separate derivation.

2. **Create `overlays/libreoffice.nix`** following the `{ inputs }: final: prev: { ... }` pattern from `td.nix`/`sidecar.nix`. The `inputs` parameter may not be needed (no flake inputs required), but include it for consistency with the existing overlay signature.

3. **Add the import to `overlays/default.nix`** with a comment noting this is a workaround for a nixpkgs bug. Include the upstream issue URL if one exists.

4. **Test all three hosts:**
   ```bash
   nix build .#nixosConfigurations.desktop.config.system.build.toplevel
   nix build .#nixosConfigurations.laptop.config.system.build.toplevel
   nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel
   ```

5. **Verify the built `noto-fonts-subset`** contains font files:
   ```bash
   # After build, inspect the noto-fonts-subset store path
   ls $(nix-store -qR result | grep noto-fonts-subset)/share/fonts/noto/
   ```

6. **Run formatting and checks:**
   ```bash
   nix develop -c treefmt
   nix flake check
   ```

### Patterns to follow

- Overlay file signature: `{ inputs }: final: prev: { ... }` (see `td.nix` line 1-2)
- Use `prev.` for the original package, `final.` only if you need the fully-overlaid package set
- Keep the overlay minimal — only override what's necessary
- Add a `# TODO: Remove when nixpkgs fixes <issue-url>` comment

### Test expectations

- All three `nix build` commands from the acceptance criteria must succeed
- LibreOffice should appear in the system profile after `nixos-rebuild switch`
- `treefmt` and `nix flake check` must pass
- No regression in font rendering (Noto fonts should still work system-wide)

### Removal criteria

This overlay should be removed when:
- The upstream nixpkgs fix is merged AND
- Our `flake.lock` is updated to a nixpkgs commit that includes the fix

Add a comment in the overlay file documenting this.
