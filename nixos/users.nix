# Caches configuration
{ config, pkgs, lib, ... }:
{
  security.sudo.wheelNeedsPassword = false;

  users = {
    defaultUserShell = pkgs.zsh;
    users.{{ ssh_username }} = {
      isNormalUser = true;
      home = "/home/{{ ssh_username }}";
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [
        {{ ssh_keys | map('regex_replace', '^(.*)$', '\"\\1\"') | join(' ') }}
      ];
    };
  };
}
