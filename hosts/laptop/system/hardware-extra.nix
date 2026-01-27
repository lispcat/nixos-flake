{ pkgs, ... }:

{
  # fix AX200 wifi issue
  boot.kernelModules = [ "iwlwifi" ];
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
    options iwlmvm power_scheme=1
  '';

  # hardware acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      intel-compute-runtime # openCL support
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Optionally, set the environment variable

  # graphics driver for xorg & wayland (try disabling for river issue)
  # services.xserver.videoDrivers = [ "modesetting" ];
}
