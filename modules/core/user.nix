# User configuration
{
  pkgs,
  username,
  customsecrets,
  ...
}:
{
  # Create the user
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "docker"
    ];
    shell = pkgs.zsh;
    hashedPassword = customsecrets.hashedPassword or null;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
