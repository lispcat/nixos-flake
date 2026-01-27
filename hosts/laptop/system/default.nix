{ user, config, lib, inputs, ... }:

{
  ## Hardware Configuration
  imports = [
    ./flags.nix
    ./hardware.nix
    ./packages-temp.nix # TODO: move these
  ];

  ## Flags
  # (no need to specify config prefix, because that's the
  # final state of the ENTIRE flake config)

  ## Host-specific configs
  boot = {
    kernel.sysctl = { "vm.swappiness" = lib.mkForce 1; };
    blacklistedKernelModules = [ "uvcvideo" ]; # disables webcam
  };

  ## Temp
  programs.wireshark.enable = true;

  programs.proxychains = {
    enable = true;
    proxyDNS = true;
    chain.type = "strict";
    proxies = {
      # We'll give our proxy a logical name, "localvpn".
      localvpn = {
        enable = true;
        type = "socks5";
        host = "127.0.0.1";
        port = 1080;
      };
    };
  };

}
