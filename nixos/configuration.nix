{ config, pkgs, lib, ... }:
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./users.nix
    ./rpi4.nix
    ./ssh.nix
  ];

  networking.hostName = "{{ ansible_hostname }}";
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
    (python39.withPackages (ps: with ps; [ pip requests ]))
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

  time.timeZone = "Europe/Warsaw";
  services.timesyncd.enable = true;

  # Nix
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "{{ nixos_system_state_version }}";
}
