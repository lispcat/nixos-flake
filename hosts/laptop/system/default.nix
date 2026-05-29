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

  ## NFS mount

  fileSystems."/home/${user}/mnt/Homelab-ro" = {
    device = "homelab:/mnt/audio";  # or use Tailscale IP directly
    fsType = "nfs";
    options = [
      # mount read-only
      "ro"

      # use NFSv4.2 - works over a single TCP port (2049), no portmapper needed
      "vers=4.2"

      # don't hang forever if the server is unreachable - fail after retries
      "soft"

      # timeout per retry attempt in 0.1s units (30 = 3s)
      "timeo=30"

      # number of retries before giving up
      "retrans=3"

      # read buffer size in bytes - larger = fewer round trips, better for streaming
      "rsize=131072"

      # don't update access timestamps on reads - reduces unnecessary writes over the network
      "noatime"

      # network filesystem - wait for network to be up before attempting mount
      "_netdev"

      # lazy mount - only mount on first access, not at boot
      "x-systemd.automount"

      # don't attempt mount until tailscale is running
      "x-systemd.requires=tailscaled.service"
      "x-systemd.after=tailscaled.service"

      # give up mounting after this long
      "x-systemd.mount-timeout=30s"

      # unmount automatically after 10 minutes of inactivity
      "x-systemd.idle-timeout=600"
    ];
  };

  # TODO: move elsewhere: sshfs homelab music mount

  # fileSystems."/home/${user}/Homelab" = {
  #   device = "rin@homelab:/mnt/music";
  #   fsType = "sshfs";
  #   options = [
  #     # read-only
  #     "ro"

  #     # path to ssh priv key (ensure pubkey in host's authorized_keys)
  #     "identityfile=/home/sui/.ssh/homelab_sshfs"

  #     # network fs, wait for network connection before mounting
  #     "_netdev"

  #     # non-root can access mount
  #     "allow_other"

  #     # lazy mounting
  #     "x-systemd.automount"

  #     # tailscale service dependency
  #     "x-systemd.requires=tailscaled.service"
  #     "x-systemd.after=tailscaled.service"

  #     # prevent hanging
  #     "x-systemd.mount-timeout=30s"

  #     # automatically reconnect if lose connection
  #     "reconnect"

  #     # start checking for reconnect after x seconds
  #     "ServerAliveInterval=15"
  #   ];
  # };
}
