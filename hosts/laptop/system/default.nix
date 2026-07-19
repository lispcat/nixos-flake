{ user, config, lib, inputs, pkgs, ... }:

let
  # use this later
  musicMountSwitch = pkgs.writeShellApplication {
    name = "music-mount-switch";
    runtimeInputs = [ pkgs.util-linux pkgs.netcat ];  # findmnt/mount live in util-linux
    text = ''
      MUSIC_PATH=/mnt/music
      NFS_MOUNTED_PATH=/mnt/homelab-rw-shared
      LOCAL_CACHE=/local/music-cache
      NFS_HOST=homelab

      is_online() { timeout 2 nc -z "$NFS_HOST" 2049 2>/dev/null; }
      current_src() { findmnt -n -o SOURCE "$MUSIC_PATH" 2>/dev/null || echo none; }

      if is_online; then
        if [[ "$(current_src)" != "$NFS_MOUNTED_PATH" ]]; then
          umount -l "$MUSIC_PATH" 2>/dev/null || true
          mount --bind "$NFS_MOUNTED_PATH" "$MUSIC_PATH"
        fi
      else
        if [[ "$(current_src)" != "$LOCAL_CACHE" ]]; then
          umount -l "$MUSIC_PATH" 2>/dev/null || true
          mount --bind "$LOCAL_CACHE" "$MUSIC_PATH"
        fi
      fi
    '';
  };
in
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

  # TODO: am i even using this?
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

  fileSystems."/mnt/homelab-ro-shared" = {
    device = "homelab:/mnt/audio/shared";  # or use Tailscale IP directly
    fsType = "nfs";
    options = [
      "ro" # mount read-only

      "vers=4.2" # use NFSv4.2 - works over a single TCP port (2049), no portmapper needed
      "soft" # don't hang forever if the server is unreachable - fail after retries
      "timeo=30" # timeout per retry attempt in 0.1s units (30 = 3s)
      "retrans=3" # number of retries before giving up
      "rsize=131072" # read buffer size in bytes - larger = fewer round trips, better for streaming
      "noatime" # don't update access timestamps on reads - reduces unnecessary writes over the network
      "_netdev" # network filesystem - wait for network to be up before attempting mount
      "x-systemd.automount" # lazy mount - only mount on first access, not at boot
      "fsc" # opt into cachefilesd

      # don't attempt mount until tailscale is running
      "x-systemd.requires=tailscaled.service"
      "x-systemd.after=tailscaled.service"

      # give up mounting after this long
      "x-systemd.mount-timeout=10s"
      "retry=0"

      # unmount automatically after 10 minutes of inactivity
      "x-systemd.idle-timeout=600"
    ];
  };

  fileSystems."/mnt/homelab-ro-downloads" = {
    device = "homelab:/mnt/audio/downloads";  # or use Tailscale IP directly
    fsType = "nfs";
    options = [
      "ro" # mount read-only

      "vers=4.2" # use NFSv4.2 - works over a single TCP port (2049), no portmapper needed
      "soft" # don't hang forever if the server is unreachable - fail after retries
      "timeo=30" # timeout per retry attempt in 0.1s units (30 = 3s)
      "retrans=3" # number of retries before giving up
      "rsize=131072" # read buffer size in bytes - larger = fewer round trips, better for streaming
      "noatime" # don't update access timestamps on reads - reduces unnecessary writes over the network
      "_netdev" # network filesystem - wait for network to be up before attempting mount
      "x-systemd.automount" # lazy mount - only mount on first access, not at boot
      "fsc" # opt into cachefilesd

      # don't attempt mount until tailscale is running
      "x-systemd.requires=tailscaled.service"
      "x-systemd.after=tailscaled.service"

      # give up mounting after this long
      "x-systemd.mount-timeout=10s"
      "retry=0"

      # unmount automatically after 10 minutes of inactivity
      "x-systemd.idle-timeout=600"
    ];
  };

  fileSystems."/mnt/homelab-rw-shared" = {
    device = "homelab:/mnt/audio/shared";  # or use Tailscale IP directly
    fsType = "nfs";
    options = [
      "rw" # mount read-write

      "vers=4.2" # use NFSv4.2 - works over a single TCP port (2049), no portmapper needed
      "soft" # don't hang forever if the server is unreachable - fail after retries
      "timeo=30" # timeout per retry attempt in 0.1s units (30 = 3s)
      "retrans=3" # number of retries before giving up
      "rsize=131072" # read buffer size in bytes - larger = fewer round trips, better for streaming
      "noatime" # don't update access timestamps on reads - reduces unnecessary writes over the network
      "_netdev" # network filesystem - wait for network to be up before attempting mount
      "x-systemd.automount" # lazy mount - only mount on first access, not at boot
      "fsc" # opt into cachefilesd

      # don't attempt mount until tailscale is running
      "x-systemd.requires=tailscaled.service"
      "x-systemd.after=tailscaled.service"

      # give up mounting after this long
      "x-systemd.mount-timeout=10s"
      "retry=0"

      # unmount automatically after 10 minutes of inactivity
      "x-systemd.idle-timeout=600"
    ];
  };

  fileSystems."/mnt/homelab-rw-downloads" = {
    device = "homelab:/mnt/audio/downloads";  # or use Tailscale IP directly
    fsType = "nfs";
    options = [
      "rw" # mount read-write

      "vers=4.2" # use NFSv4.2 - works over a single TCP port (2049), no portmapper needed
      "soft" # don't hang forever if the server is unreachable - fail after retries
      "timeo=30" # timeout per retry attempt in 0.1s units (30 = 3s)
      "retrans=3" # number of retries before giving up
      "rsize=131072" # read buffer size in bytes - larger = fewer round trips, better for streaming
      "noatime" # don't update access timestamps on reads - reduces unnecessary writes over the network
      "_netdev" # network filesystem - wait for network to be up before attempting mount
      "x-systemd.automount" # lazy mount - only mount on first access, not at boot
      "fsc" # opt into cachefilesd

      # don't attempt mount until tailscale is running
      "x-systemd.requires=tailscaled.service"
      "x-systemd.after=tailscaled.service"

      # give up mounting after this long
      "x-systemd.mount-timeout=10s"
      "retry=0"

      # unmount automatically after 10 minutes of inactivity
      "x-systemd.idle-timeout=600"
    ];
  };

  # dependency for NFS read caching
  services.cachefilesd = {
    enable = true;
    cacheDir = "/var/cache/fscache";  # use fschache
    extraConfig = ''
      brun 10%
      bcull 7%
      bstop 3%
    '';
  };

  # mount the custom fscache
  fileSystems."/var/cache/fscache" = {
    device = "/var/lib/fscache.img";
    fsType = "ext4";
    options = [ "loop" "rw" ];
  };

  # make sure the loop mount is up before cachefilesd starts
  systemd.services.cachefilesd = {
    after = [ "var-cache-fscache.mount" ];
    requires = [ "var-cache-fscache.mount" ];
  };

  ### Automount local music cache ###

  environment.systemPackages = [ musicMountSwitch ];

  systemd.services.music-mount-switch = {
    description = "Switch /mnt/music between NFS and local cache";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${musicMountSwitch}/bin/music-mount-switch";
    };
  };

  systemd.timers.music-mount-switch = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitActiveSec = "20s";
    };
  };

  # ensure /mnt/music exists as an empty mountpoint dir
  systemd.tmpfiles.rules = [
    "d /mnt/music 0755 root root -"
  ];

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
