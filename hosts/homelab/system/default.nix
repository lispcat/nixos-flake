{ pkgs, user, config, lib, inputs, ... }:

{
  ## Hardware Configuration
  imports = [
    ./flags.nix
    ./hardware.nix
    ./packages-temp.nix
  ];

  ## Host-specific configs

  # Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = [ "uvcvideo" ]; # disables webcam
  };

  # Auto-login
  services.getty.autologinUser = "rin";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # TODO: move elsewhere (also exists in laptop host default config)
  # programs.proxychains = {
  #   enable = true;
  #   proxyDNS = true;
  #   chain.type = "strict";
  #   proxies = {
  #     # We'll give our proxy a logical name, "localvpn".
  #     localvpn = {
  #       enable = true;
  #       type = "socks5";
  #       host = "127.0.0.1";
  #       port = 1080;
  #     };
  #   };
  # };

  # # Don't touch!
  # system.stateVersion = "25.05"; # Did you read the comment?
}
