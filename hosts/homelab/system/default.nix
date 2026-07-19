{ pkgs, user, config, lib, inputs, ... }:

{
  ## Hardware Configuration
  imports = [
    ./flags.nix
    ./hardware.nix
    ./packages-temp.nix
  ];

  #### Host-specific configs ####

  ## Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = [ "uvcvideo" ]; # disables webcam
  };

  ## Auto-login
  services.getty.autologinUser = "rin";

  ## NFS server
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/audio/shared 100.71.163.113(rw,no_subtree_check,all_squash,anonuid=1000,anongid=100,fsid=1)
      /mnt/audio/downloads 100.71.163.113(rw,no_subtree_check,all_squash,anonuid=1000,anongid=100)
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

  ## HDD mount
  fileSystems = {
    "/mnt/hdd" = {
      device = "/dev/disk/by-label/MusicDrive";
      fsType = "ext4";
      options = [
        "defaults"
        "nofail"          # don't block boot if drive is absent
        "noatime"         # don't update access timestamps - good for HDDs
        "x-systemd.automount"  # mount on first access, not at boot
      ];
    };
  };

  ## MergerFS mount over /mnt/audio/internal and /mnt/hdd
  environment.systemPackages = [
    pkgs.mergerfs  # needed or else will fail
  ];
  fileSystems = {
    # 2. mergerfs union over internal + HDD
    "/mnt/audio/shared" = {
      device = "/mnt/hdd/audio/shared:/mnt/audio/internal";
      fsType = "fuse.mergerfs";
      options = [
        "defaults"
        "allow_other"         # lets other users/services (navidrome) access it
        "use_ino"             # use real inode numbers - important for beets
        "cache.files=off"     # safer for NFS/network-style access patterns
        "dropcacheonclose=true"
        "category.create=ff"  # NEW files always go to HDD (first found with space)
        "moveonenospc=true"   # if one branch fills up, move to another
        "minfreespace=5G"     # don't fill a branch below 5 GB
      ];
      depends = [ "/mnt/hdd" "/mnt/audio/internal" ];
    };
  };

  ## ensure directories existence
  systemd.tmpfiles.rules = [
    "d /mnt/audio/internal 0770 rin users -"
    "d /mnt/audio/shared   0770 rin users -"
    "d /mnt/audio/staging  0770 rin users -"
    "d /mnt/hdd            0755 root root -"
  ];

  ### Minecraft Server ###

  services.minecraft-server = {
    enable = true;
    eula = true;
    package = pkgs.paperServers.paper;
    # Manually handle server.properties, whitelist, ops, bans, etc.
    # Editable in /var/lib/minecraft-server/server.properties
    declarative = false;
    jvmOpts = "-Xms4096M -Xmx7168M -XX:+UseG1GC -XX:+ParallelRefProcEnabled";
  };

  # port for mc
  networking.firewall.allowedTCPPorts = [ 25565 ];

  # limit resources
  systemd.services.minecraft-server.serviceConfig = {
    MemoryMax = "8G";
    MemoryHigh = "7G";
    CPUQuota = "350%";
    CPUWeight = 100;
    IOWeight = 50;
  };

  # for RCON
  # ```
  # # in /var/lib/minecraft-server/server.properties
  # enable-rcon=true
  # rcon.port=25575
  # rcon.password=<your password>
  # ```




  # # Don't touch!
  # system.stateVersion = "25.05"; # Did you read the comment?
}
