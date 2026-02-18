# Fastfetch system info display (catnap-inspired box layout)
{ pkgs, ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "builtin";
        source = "nixos";
        padding = {
          top = 1;
          right = 4;
          left = 1;
        };
      };
      display = {
        separator = " ";
      };
      modules = [
        {
          key = "╭───────────╮";
          type = "custom";
        }
        {
          key = "│ {#34}{icon} distro  {#keys}│";
          type = "os";
        }
        {
          key = "│ {#35}󰌽 kernel  {#keys}│";
          type = "kernel";
        }
        {
          key = "│ {#36}󰍹 wm      {#keys}│";
          type = "wm";
        }
        {
          key = "│ {#31}󰆍 term    {#keys}│";
          type = "terminal";
        }
        {
          key = "│ {#32}󰆍 shell   {#keys}│";
          type = "shell";
        }
        {
          key = "│ {#33}󰍛 cpu     {#keys}│";
          type = "cpu";
          showPeCoreCount = true;
        }
        {
          key = "│ {#34}󰉉 disk    {#keys}│";
          type = "disk";
          folders = "/";
        }
        {
          key = "│ {#36}󰍛 memory  {#keys}│";
          type = "memory";
        }
        {
          key = "│ {#33}󰅐 uptime  {#keys}│";
          type = "uptime";
        }
        {
          key = "├───────────┤";
          type = "custom";
        }
        {
          key = "│ {#39}󰏘 colors  {#keys}│";
          type = "colors";
          symbol = "circle";
        }
        {
          key = "╰───────────╯";
          type = "custom";
        }
      ];
    };
  };
}
