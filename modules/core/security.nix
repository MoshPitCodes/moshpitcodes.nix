# Security configuration
{ ... }:
{
  # Enable sudo
  security.sudo.enable = true;

  # RTKit for real-time scheduling (needed by PipeWire)
  security.rtkit.enable = true;

  # PAM configuration for swaylock
  security.pam.services.swaylock = { };
  security.pam.services.hyprlock = { };

  # Polkit for privilege escalation
  security.polkit.enable = true;
}
