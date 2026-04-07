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

  # # Don't touch!
  # system.stateVersion = "25.05"; # Did you read the comment?
}
