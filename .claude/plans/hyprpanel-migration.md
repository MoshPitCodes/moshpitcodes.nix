# HyprPanel Migration Plan

**Status**: Investigation
**Created**: 2026-02-16
**Current Setup**: waybar + swaync + swayosd
**Target**: HyprPanel (all-in-one solution)

---

## Executive Summary

HyprPanel is an all-in-one panel for Hyprland that replaces waybar, swaync, swayosd, and other system utilities with a single, integrated solution. It's available in nixpkgs with home-manager support.

**⚠️ Important Note**: HyprPanel is currently in **maintenance mode** - bugs will be fixed, but no new features are being added. The maintainer is working on a successor called "Wayle".

---

## Current Setup Analysis

### What You're Using Now

1. **waybar** - Status bar with:
   - Workspace indicators (3 per monitor)
   - Clock (center)
   - CPU usage with bar graph
   - File manager launcher
   - EasyEffects launcher
   - Audio controls (pulseaudio)
   - Backlight control (laptop only)
   - Battery indicator (laptop only)
   - Network status
   - Bluetooth status
   - System tray
   - Notification indicator (swaync integration)

2. **swaync** (SwayNotificationCenter):
   - Notification popup (5s timeout)
   - Control center panel (right side)
   - Do Not Disturb toggle
   - Notification history
   - Custom Everforest styling

3. **swayosd** (SwayOSD):
   - Volume OSD overlay
   - Brightness OSD overlay
   - Custom Everforest styling

### Files to Replace/Modify

```
modules/home/waybar/default.nix        → Replace
modules/home/swaync.nix                → Replace
modules/home/swayosd.nix               → Replace
modules/home/default.nix               → Update imports
modules/home/hyprland/default.nix      → Update autostart
```

---

## HyprPanel Features & Capabilities

### What HyprPanel Provides

✅ **Integrated Components**:
- Status bar (replaces waybar)
- Notification center (replaces swaync)
- OSD for volume/brightness (replaces swayosd)
- Audio device control (replaces pavucontrol popups)
- Network manager (replaces nm-applet)
- Bluetooth manager (replaces blueman)
- System monitoring (CPU, RAM, temp)
- Media controls
- Quick settings panel

✅ **Built-in Features**:
- Workspace indicators
- Clock/calendar
- System tray
- Battery status
- Network status
- Bluetooth status
- Volume controls
- Brightness controls
- Notification management
- Fully themeable UI

✅ **NixOS Support**:
- Available in nixpkgs
- Home-manager module: `programs.hyprpanel.enable = true`
- Active maintenance (bug fixes)

---

## Pros & Cons Analysis

### Advantages of Migration

✅ **Integration Benefits**:
- Single unified theme across all components
- No integration issues between separate tools
- Consistent styling automatically
- Less configuration complexity

✅ **Feature Parity**:
- All current features available
- Additional features (media controls, quick settings)
- Better OSD integration

✅ **Performance**:
- Single process instead of 3+ separate daemons
- Potentially lower memory usage
- AGS (GTK-based) is mature and stable

✅ **Customization**:
- Extensive theming options
- Custom module support
- CLI control commands

### Disadvantages & Risks

⚠️ **Major Concerns**:

1. **Maintenance Status**:
   - Currently in maintenance mode (no new features)
   - Successor "Wayle" in development (unknown timeline)
   - May need to migrate again in the future

2. **Feature Gaps**:
   - Your custom waybar modules (filemanager, easyeffects launchers)
   - Specific workspace assignments per monitor
   - Custom CPU bar graph format
   - Potential loss of specific styling control

3. **Migration Effort**:
   - Need to rewrite entire panel configuration
   - Learn new configuration format (AGS-based)
   - Recreate Everforest theme from scratch
   - Test all functionality across 3 monitors

4. **Dependency**:
   - Adds AGS (Aylur's GTK Shell) dependency
   - Requires JetBrainsMono Nerd Font (you use FiraCode)
   - Less control over individual component updates

5. **Rollback Complexity**:
   - If issues arise, need to restore 3+ configurations
   - Testing period will show gaps in functionality
   - May discover missing features after full migration

---

## Migration Strategy (If Proceeding)

### Phase 1: Parallel Testing (Recommended)

1. **Keep current setup working**
2. **Add HyprPanel in test mode**:
   ```nix
   programs.hyprpanel = {
     enable = true;
     # Test configuration
   };
   ```
3. **Test for 1-2 weeks** alongside current setup
4. **Document any missing features or issues**

### Phase 2: Configuration Recreation

1. **Theme Migration**:
   - Recreate Everforest colors in HyprPanel
   - Match current styling as closely as possible
   - Test on all 3 monitors

2. **Feature Mapping**:
   - Workspace indicators → HyprPanel workspaces module
   - Clock → HyprPanel clock module
   - CPU → HyprPanel system monitor
   - Custom launchers → Create custom HyprPanel modules
   - Notifications → Configure HyprPanel notification center
   - OSD → Configure HyprPanel OSD

3. **Keybinding Updates**:
   - Update Hyprland config for new notification toggle
   - Verify OSD keybindings work

### Phase 3: Cutover

1. **Disable old components**:
   ```nix
   programs.waybar.enable = false;
   # Remove swaync.nix import
   # Remove swayosd.nix import
   ```

2. **Enable HyprPanel fully**

3. **Test all functionality**

---

## Alternative: Stay with Current Setup

### Reasons to Keep Current Setup

✅ **Stability**: Current setup is proven and working perfectly
✅ **Maintenance**: waybar + swaync are actively maintained with new features
✅ **Customization**: You have full control over each component
✅ **No Risk**: Avoid migration complexity and potential issues
✅ **Modularity**: Can update/replace individual components independently

### When Current Setup Makes Sense

- Current setup meets all your needs
- Heavy customization would be hard to replicate
- Don't want to invest time in migration that may need to be repeated (Wayle)
- Value stability over integration

---

## Recommendation

### 🎯 **Suggested Approach: Wait or Test Carefully**

**Reasoning**:

1. **Maintenance Mode Concern**: HyprPanel is not actively developed (new features). Migrating to a tool that's being phased out seems risky.

2. **Successor in Development**: "Wayle" is coming - might be better to wait for that and migrate once, rather than migrate twice.

3. **Current Setup Works**: Your waybar + swaync + swayosd configuration is:
   - Fully functional
   - Beautifully themed
   - Well-maintained upstream
   - Modular and flexible

4. **Migration Effort**: The effort to migrate (recreate theme, custom modules, testing) is significant for a tool in maintenance mode.

### If You Still Want to Try

**Low-Risk Approach**:
1. Enable HyprPanel in parallel (don't disable current setup)
2. Test for 2-3 weeks
3. Document every missing feature or issue
4. Only commit to full migration if HyprPanel proves clearly superior
5. Keep waybar config files for easy rollback

### Alternative: Wait for Wayle

Monitor the successor project's development and migrate to Wayle when it's stable and feature-complete.

---

## Implementation Steps (If Proceeding)

### 1. Create Backup Branch

```bash
git checkout -b test-hyprpanel
```

### 2. Add HyprPanel Module

Create `modules/home/hyprpanel.nix`:
```nix
{ pkgs, lib, ... }:
{
  programs.hyprpanel = {
    enable = true;
    # Configuration here
  };
}
```

### 3. Import in Parallel

In `modules/home/default.nix`:
```nix
imports = [
  ./waybar/default.nix      # Keep for now
  ./swaync.nix              # Keep for now
  ./swayosd.nix             # Keep for now
  ./hyprpanel.nix           # Add new
  # ...
];
```

### 4. Test & Evaluate

- Use for 1-2 weeks
- Document pros/cons
- Decide based on real experience

---

## Resources

### Documentation

- [HyprPanel Official Docs](https://hyprpanel.com/getting_started/hyprpanel.html)
- [HyprPanel Installation Guide](https://hyprpanel.com/getting_started/installation.html)
- [HyprPanel GitHub](https://github.com/Jas-SinghFSU/HyprPanel)
- [MyNixOS HyprPanel Package](https://mynixos.com/nixpkgs/package/hyprpanel)

### NixOS Resources

- [Hyprland on NixOS – Hyprland Wiki](https://wiki.hypr.land/Nix/Hyprland-on-NixOS/)
- [NixOS Discourse: HyprPanel Install](https://discourse.nixos.org/t/hyprpanel-install/62349)
- [NixOS Package Request](https://github.com/NixOS/nixpkgs/issues/350324)

---

## Decision

**Status**: ✅ **DECIDED - Staying with Current Setup**

**Decision Date**: 2026-02-16

**Rationale**:
- Current waybar + swaync + swayosd setup is stable and fully functional
- HyprPanel's maintenance mode status presents migration risk
- Avoiding effort and complexity of recreating theme and custom modules
- Prefer stability over integration for core system components

**Current Stack** (Keeping):
- ✅ waybar - Status bar with Everforest theme
- ✅ swaync - Notification center with custom styling
- ✅ swayosd - OSD overlays for volume/brightness

**Future Consideration**:
- May revisit when "Wayle" (HyprPanel successor) is stable and mature
- Current setup remains maintainable with active upstream development

---

**Last Updated**: 2026-02-16
**Investigation Closed**: User decision to maintain current setup
