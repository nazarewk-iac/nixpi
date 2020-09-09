# https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598/4

{ config, pkgs, lib, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;

  # Kernel configuration
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = [ "cma=64M" "console=tty0" ];

  # Enable additional firmware (such as Wi-Fi drivers).
  hardware.enableRedistributableFirmware = true;


  # Networking (see official manual or `/config/sd-image.nix` in this repo for other options)
  networking.hostName = "nixpi-hostname"; # unleash your creativity!
  networking.firewall = {
    allowedTCPPorts = [
      5000 # nix-serve
      6443 # Kubernetes API @ k3s
      10250 # Kubelet @ k3s
    ];
    allowedUDPPorts = [
      8472 # Flannel @ k3s
    ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # customize as needed!
    vim
    git
    htop
    raspberrypi-tools
    k3s
    iptables
    (python38.withPackages (ps: with ps; [ pip ipython requests ]))
  ];

  programs = {
    zsh = {
      enable = true;
      interactiveShellInit = ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc

        # Make user colour green in prompt instead of default blue
        zstyle ':prompt:grml:left:items:user' pre '%F{green}%B'
      '';
      promptInit = "";
    };
  };

  # Users

  users = {
    defaultUserShell = pkgs.zsh;
    users.nazarewk = {
      isNormalUser = true;
      home = "/home/nazarewk";
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAYEAvM4y0G5vZ2OYlSeGn2w7y/s+VZMzhGGb9rlUkDtWtwvsE2TWlApFyHggn6qObmQ5DUOu0Mhy6l/ojylyp2Q/C7FMoQWkeBorLKvxf8KFE1lJktCXCxJyptDn8kkNi6Fxszig/flrp5lSWWjDCafyVeyFhvMo22fblzjPOG//wu0+RnOLn9eiWC2CUvJjG11AH+AxWI4UMXY93gq5K1YVLd3EmhI/L1ITAoY3cXoheP0TW9epqe0Zq6lGO+gLiYeWgZJiolSqcHCkTzopbkIZ2cP+yEdeJrYp8ibdO7H0oyXOy48yPElkEobcISzQmTayXQfXyr9YzFPGdM0ZxxKPfpmMox2DTL+mpo1etLOf7ihJNBoR6aAcAWeYLdfqmIlWnVVySW1RPcq31tR4uCP6jpDsbEArXP7lttkWzb0EuBRKN94OVsl7gHuqSSdnrWJwU6jn8EAi9krRQtOKUrz62nOmAkWIe/4fM/3CVjuOgTSUkmuu15SgrbN9aLYp0ct/ nazarewk.id_rsa"
      ];
    };
  };

  # Miscellaneous
  time.timeZone = "Europe/Warsaw"; # you probably want to change this -- otherwise, ciao!
  services.openssh.enable = true;

  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = "/var/nixpi-hostname-0-priv-key.pem";
  };

  security.sudo.wheelNeedsPassword = false;

  # Nix
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.binaryCaches = [ http://192.168.0.8:5000 http://192.168.0.9:5000 http://192.168.0.10:5000 ];
  nix.trustedBinaryCaches = [ http://192.168.0.8:5000 http://192.168.0.9:5000 http://192.168.0.10:5000 ];
  nix.binaryCachePublicKeys = [
    "nixpi-0-0:bCX8+fZYfjniM7FGY3InCSLI0A0uq/D6XlPlk04K0Qg="
    "nixpi-1-0:xXRmdogYTtnn7vQOLNgX/ISLKmuvCcVZd/W8a/Ved4g="
    "nixpi-2-0:ghVm9S4gjBHV6ZomM79OOyRzd+qfS6BuLkMl40NT8KE="
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.03";
}
