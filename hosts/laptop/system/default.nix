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
  # programs.wireshark.enable = true;

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

  # TODO: move elsewhere: sshfs homelab music mount

  fileSystems."/home/${user}/Homelab" = {
    device = "rin@homelab:/home/rin";
    fsType = "sshfs";
    options = [
      # path to ssh priv key (ensure pubkey in host's authorized_keys)
      "identityfile=/home/sui/.ssh/homelab_sshfs"

      # network fs, wait for network connection before mounting
      "_netdev"

      # non-root can access mount
      "allow_other"

      # lazy mounting
      "x-systemd.automount"

      # tailscale service dependency
      "x-systemd.requires=tailscaled.service"
      "x-systemd.after=tailscaled.service"

      # prevent hanging
      "x-systemd.mount-timeout=30s"

      # automatically reconnect if lose connection
      "reconnect"

      # start checking for reconnect after x seconds
      "ServerAliveInterval=15"
    ];
  };
}
