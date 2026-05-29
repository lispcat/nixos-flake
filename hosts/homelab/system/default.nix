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

  # NFS server

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/audio 100.71.163.113(ro,no_subtree_check,all_squash,anonuid=1000,anongid=100)
    '';
    # Pin auxiliary ports for clean firewall rules
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort  = 4000;
  };
  # Restrict NFS to Tailscale interface only
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i tailscale0 -p tcp --dport 2049 -j ACCEPT
    iptables -A INPUT -i tailscale0 -p udp --dport 2049 -j ACCEPT
  '';


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
