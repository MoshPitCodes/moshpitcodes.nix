# Notification Daemon Alternatives

**Current**: SwayNotificationCenter (swaync)
**Status**: Investigating alternatives
**Created**: 2026-02-16

---

## Overview

Comparison of notification daemons for Hyprland/Wayland to potentially replace swaync.

---

## Current Setup: swaync (SwayNotificationCenter)

### Features You're Using

✅ **Notification popup** - Temporary display (5s timeout)
✅ **Control center** - Panel with notification history
✅ **Do Not Disturb** - Toggle to silence notifications
✅ **Custom styling** - Everforest theme applied
✅ **Waybar integration** - Indicator shows notification status
✅ **Persistent history** - Review past notifications

### What You Like/Dislike

**Pros**:
- Full notification center with history
- DND toggle
- Good waybar integration
- Customizable styling

**Cons** (potential):
- ❓ Too heavy/feature-rich?
- ❓ Styling limitations?
- ❓ Performance concerns?

---

## Alternative 1: **mako**

### Overview
Lightweight Wayland-specific notification daemon. Minimalist approach focused on displaying notifications without a persistent control center.

### Features

✅ **Auto-start** - Launches automatically on first notification (no manual service needed)
✅ **Lightweight** - Very low resource usage
✅ **Wayland-native** - Built specifically for Wayland
✅ **Layer shell** - Proper Wayland positioning
✅ **Theming** - Full color/font customization
✅ **Actions** - Supports notification actions
✅ **Grouping** - Groups notifications from same app

❌ **No notification center** - No history panel
❌ **No DND toggle UI** - Would need separate control
❌ **No persistent panel** - Notifications disappear after timeout

### NixOS Integration

```nix
services.mako = {
  enable = true;
  backgroundColor = "#2d353b";
  textColor = "#d3c6aa";
  borderColor = "#d3c6aa";
  font = "FiraCode Nerd Font 12";
  defaultTimeout = 5000;
  # ... more options
};
```

### Home Manager Support
✅ Full home-manager module: `services.mako`

### Best For
- Users who want minimal, ephemeral notifications
- Don't need notification history
- Want lowest resource usage
- Prefer simplicity over features

---

## Alternative 2: **dunst**

### Overview
Traditional, highly customizable notification daemon. Originally for X11, now with Wayland support. Very mature and feature-rich.

### Features

✅ **Highly customizable** - Extensive configuration options
✅ **Rules engine** - Complex notification filtering/routing
✅ **Shell scripting** - Extend functionality via scripts
✅ **Multiple urgency levels** - Different styling per urgency
✅ **History** - Can browse notification history (via dunstctl)
✅ **DND mode** - Pause notifications (via dunstctl)
✅ **Actions** - Supports notification actions
✅ **Stacking/replacing** - Smart notification management

⚠️ **No GUI control panel** - Command-line control only (dunstctl)
⚠️ **Originally X11** - Wayland support added later

### NixOS Integration

```nix
services.dunst = {
  enable = true;
  settings = {
    global = {
      font = "FiraCode Nerd Font 12";
      format = "<b>%s</b>\n%b";
      frame_color = "#d3c6aa";
      background = "#2d353b";
      foreground = "#d3c6aa";
      # ... extensive options
    };
    urgency_low = {
      timeout = 3;
    };
    urgency_normal = {
      timeout = 5;
    };
    urgency_critical = {
      timeout = 0;
    };
  };
};
```

### Home Manager Support
✅ Full home-manager module: `services.dunst`

### Best For
- Power users who want maximum control
- Those who like rule-based notification management
- CLI-comfortable users (dunstctl for history/control)
- Need scripting/automation capabilities

---

## Alternative 3: **fnott**

### Overview
Keyboard-driven, lightweight Wayland notification daemon. Inspired by Dunst but built for Wayland from scratch.

### Features

✅ **Keyboard-driven** - Navigate notifications with keyboard
✅ **Lightweight** - Minimal resource usage
✅ **Wayland-native** - Built for wlroots compositors
✅ **Dunst-style config** - Easy migration if coming from dunst
✅ **Actions** - Supports notification actions
✅ **Multiple urgency levels** - Different styling per urgency
✅ **INI config** - Simple configuration format

❌ **No GUI control panel** - No persistent history UI
❌ **Less mature** - Newer than dunst/mako
⚠️ **Keyboard focus** - May not suit all workflows

### NixOS Integration

```nix
services.fnott = {
  enable = true;
  settings = {
    main = {
      font = "FiraCode Nerd Font:size=12";
      background = "2d353bff";
      text = "d3c6aaff";
      border-color = "d3c6aaff";
      # ... more options
    };
  };
};
```

### Home Manager Support
✅ Full home-manager module: `services.fnott`

### Best For
- Keyboard-centric workflows
- Want lightweight + keyboard control
- Coming from dunst (similar config style)
- Wayland purists

---

## Alternative 4: Keep **swaync** (Current)

### Why Stay

✅ **Feature-complete** - Has everything you need
✅ **Notification center** - Full history panel
✅ **DND toggle** - Easy UI control
✅ **Already themed** - Everforest styling done
✅ **Waybar integrated** - Indicator working perfectly
✅ **Actively maintained** - Regular updates

### Reasons to Switch

❓ You haven't mentioned specific issues
❓ Current setup seems to work well

---

## Comparison Matrix

| Feature | swaync (current) | mako | dunst | fnott |
|---------|------------------|------|-------|-------|
| **Notification Center** | ✅ Full panel | ❌ No | ⚠️ CLI only | ❌ No |
| **Notification History** | ✅ Persistent | ❌ No | ✅ Via dunstctl | ❌ No |
| **DND Toggle** | ✅ GUI | ❌ No | ✅ Via dunstctl | ❌ No |
| **Waybar Integration** | ✅ Native | ⚠️ Custom script | ⚠️ Custom script | ⚠️ Custom script |
| **Resource Usage** | Medium | Very Low | Low | Very Low |
| **Customization** | Good | Good | Excellent | Good |
| **Theming** | CSS | Config | Config | Config |
| **Wayland Native** | ✅ Yes | ✅ Yes | ⚠️ Added later | ✅ Yes |
| **Keyboard Control** | Mouse | No | Yes (dunstctl) | ✅ Yes |
| **Actions Support** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Rule Engine** | Basic | Basic | ✅ Advanced | Basic |
| **Maturity** | Mature | Mature | Very Mature | Newer |
| **Home Manager** | ❌ Manual config | ✅ services.mako | ✅ services.dunst | ✅ services.fnott |

---

## Recommendation by Use Case

### 🎯 **Keep swaync** if you want:
- Notification center with persistent history
- GUI control for DND/settings
- Current setup works fine
- Don't want to lose waybar integration

### 🪶 **Switch to mako** if you want:
- Minimal, lightweight notifications
- Don't need notification history
- Just want ephemeral popups
- Simplest possible setup

### 🔧 **Switch to dunst** if you want:
- Maximum customization power
- Advanced notification rules
- CLI control is fine
- Scripting/automation capabilities

### ⌨️ **Switch to fnott** if you want:
- Keyboard-driven workflow
- Lightweight like mako
- Dunst-style configuration
- Wayland-native implementation

---

## Migration Complexity

### Low Effort: **mako** or **fnott**
- Simple configuration
- Home-manager module available
- Minimal feature set = less to configure
- Quick to theme

**Estimated time**: 30-60 minutes

### Medium Effort: **dunst**
- More configuration options
- Rule engine requires learning
- Need to set up dunstctl integration
- More theming options

**Estimated time**: 1-2 hours

### Zero Effort: **Keep swaync**
- Already working
- Already themed
- No migration needed

**Estimated time**: 0 minutes

---

## What You'd Lose (Switching Away from swaync)

❌ **Notification Center UI** - No persistent panel to review history
❌ **Waybar Integration** - Would need custom scripts for notification count
❌ **DND Toggle UI** - Would need CLI commands or custom waybar module
❌ **Current Theme** - Would need to recreate in new format
❌ **Clear All Button** - Easy bulk dismiss

## What You'd Gain

### With mako:
✅ Lower resource usage
✅ Auto-start capability
✅ Simpler configuration

### With dunst:
✅ Advanced notification rules
✅ Shell scripting integration
✅ More customization options
✅ Mature, battle-tested

### With fnott:
✅ Keyboard control
✅ Lower resource usage
✅ Wayland-native performance

---

## My Recommendation

### 🤔 **Question First: Why Switch?**

Before recommending an alternative, I need to understand:
- What issue are you experiencing with swaync?
- What feature do you want that swaync doesn't have?
- Is resource usage a concern?
- Do you use the notification center history?
- Do you need the DND toggle UI?

### If You Want Minimal/Lightweight:

**Choose mako** - Simplest lightweight option with auto-start

### If You Want Power/Control:

**Choose dunst** - Maximum customization and rule engine

### If You're Keyboard-Focused:

**Choose fnott** - Keyboard-driven, lightweight, Wayland-native

### If Current Setup Works:

**Keep swaync** - Don't fix what isn't broken

---

## Example Configurations

### mako (Everforest Theme)

```nix
services.mako = {
  enable = true;

  # Everforest colors
  backgroundColor = "#2d353b";
  textColor = "#d3c6aa";
  borderColor = "#d3c6aa";
  progressColor = "over #a7c080";

  # Fonts
  font = "FiraCode Nerd Font 12";

  # Behavior
  defaultTimeout = 5000;
  ignoreTimeout = false;
  layer = "overlay";

  # Positioning
  anchor = "top-right";
  margin = "10";
  padding = "10";
  borderSize = 2;
  borderRadius = 6;

  # Urgency styling
  extraConfig = ''
    [urgency=low]
    border-color=#a7c080
    default-timeout=3000

    [urgency=critical]
    border-color=#e67e80
    default-timeout=0
  '';
};
```

### dunst (Everforest Theme)

```nix
services.dunst = {
  enable = true;

  settings = {
    global = {
      # Display
      monitor = 0;
      follow = "mouse";

      # Geometry
      width = 360;
      height = 300;
      origin = "top-right";
      offset = "10x10";

      # Style
      font = "FiraCode Nerd Font 12";
      frame_width = 2;
      frame_color = "#d3c6aa";
      separator_color = "frame";
      corner_radius = 6;

      # Behavior
      timeout = 5;
      idle_threshold = 120;
      show_indicators = true;

      # Format
      format = "<b>%s</b>\n%b";
      alignment = "left";
      vertical_alignment = "center";
      markup = "full";
    };

    urgency_low = {
      background = "#2d353b";
      foreground = "#d3c6aa";
      frame_color = "#a7c080";
      timeout = 3;
    };

    urgency_normal = {
      background = "#2d353b";
      foreground = "#d3c6aa";
      frame_color = "#d3c6aa";
      timeout = 5;
    };

    urgency_critical = {
      background = "#2d353b";
      foreground = "#d3c6aa";
      frame_color = "#e67e80";
      timeout = 0;
    };
  };
};
```

### fnott (Everforest Theme)

```nix
services.fnott = {
  enable = true;

  settings = {
    main = {
      # Font
      font = "FiraCode Nerd Font:size=12";

      # Positioning
      anchor = "top-right";
      margin = 10;

      # Styling
      background = "2d353bff";
      text = "d3c6aaff";
      border-color = "d3c6aaff";
      border-size = 2;
      border-radius = 6;
      padding-horizontal = 10;
      padding-vertical = 10;

      # Behavior
      default-timeout = 5;
      idle-timeout = 120;
    };

    low = {
      border-color = "a7c080ff";
      default-timeout = 3;
    };

    critical = {
      border-color = "e67e80ff";
      default-timeout = 0;
    };
  };
};
```

---

## Migration Steps (If Switching)

### 1. Create Test Branch

```bash
git checkout -b test-notification-daemon
```

### 2. Add New Daemon Config

Create `modules/home/<daemon-name>.nix` with configuration above

### 3. Update imports

In `modules/home/default.nix`:
```nix
imports = [
  # ./swaync.nix         # Disable old
  ./<daemon-name>.nix    # Enable new
  # ...
];
```

### 4. Update Waybar (If Needed)

For mako/dunst/fnott, you'll need to create custom waybar module for notification count:

```nix
"custom/notification" = {
  exec = ""; # Custom script to count notifications
  # ... implementation needed
};
```

### 5. Rebuild and Test

```bash
home-manager switch --flake .
# or
sudo nixos-rebuild switch --flake .#desktop --impure
```

### 6. Test Functionality

- Send test notifications: `notify-send "Test" "Message"`
- Check styling
- Verify timeout behavior
- Test actions (if applicable)

---

## Resources

### Documentation

- [Hyprland Must-Have Utilities](https://wiki.hypr.land/Useful-Utilities/Must-have/)
- [Desktop Notifications - ArchWiki](https://wiki.archlinux.org/title/Desktop_notifications)
- [Mako Documentation](https://www.lorenzobettini.it/2023/11/hyprland-and-notifications-with-mako/)
- [Awesome Hyprland](https://github.com/hyprland-community/awesome-hyprland)

### NixOS Home Manager Options

- [services.mako - MyNixOS](https://github.com/nix-community/home-manager/blob/master/modules/services/mako.nix)
- [services.dunst - MyNixOS](https://mynixos.com/home-manager/options/services.dunst)
- [services.fnott - MyNixOS](https://mynixos.com/home-manager/options/services.fnott)

---

## Decision

**Status**: ⏸️ **Awaiting User Input**

**Questions**:
1. What issues are you experiencing with swaync?
2. Do you use the notification center history feature?
3. Is resource usage a concern?
4. Would you prefer keyboard or mouse control?
5. Do you need DND toggle UI or is CLI okay?

**Next Steps**:
- Clarify requirements
- Choose alternative based on needs
- Create test configuration
- Test for 1-2 days before fully switching

---

**Last Updated**: 2026-02-16
