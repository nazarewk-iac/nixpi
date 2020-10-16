# Caches configuration
{ config, pkgs, lib, ... }:
{
  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = "/var/{{ ansible_hostname }}-0-priv-key.pem";
  };
  nix.binaryCaches = [ {{ other_caches | join(' ') }} ];
  nix.trustedBinaryCaches = [ {{ other_caches | join(' ') }} ];
  nix.binaryCachePublicKeys = [
    "nixpi-0-0:bCX8+fZYfjniM7FGY3InCSLI0A0uq/D6XlPlk04K0Qg="
    "nixpi-1-0:xXRmdogYTtnn7vQOLNgX/ISLKmuvCcVZd/W8a/Ved4g="
    "nixpi-2-0:ghVm9S4gjBHV6ZomM79OOyRzd+qfS6BuLkMl40NT8KE="
  ];
}
