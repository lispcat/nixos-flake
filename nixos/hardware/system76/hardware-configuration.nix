# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, user, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  ## Systemd-boot EFI boot loader:
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## SSD
  
  services.fstrim.enable = true;

  ## Btrfs

  services.btrfs.autoScrub.enable = true;

  ### Creating subvolumes:
  # - mv ~/Games ~/Games_backup
  # - sudo btrfs subvolume create ~/@Games
  # - sudo chown ${USER}:users ~/Games
  # - sudo chattr +C ~/Games
  # - mv ~/Games_backup/* ~/Games
  # - rmdir ~/Games_backup
  # - (use `lsattr ~`to view attrs)
  # - (use `sudo btrfs subvolume list /` to list all subvolumes)
  ### Nodatacow subvolumes:
  #  /.swapvol
  #  ~/Games
  #  ~/vm

  ## Filesystems:
  
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d1e0b46b-68b9-4a9d-956c-2ae73b0450f8";
      fsType = "btrfs";
      options = [ "subvol=@root" "compress=zstd" "noatime" ];
    };

  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/37ebb4b9-7cb9-444b-a75c-a431df7ce846";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/d1e0b46b-68b9-4a9d-956c-2ae73b0450f8";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/d1e0b46b-68b9-4a9d-956c-2ae73b0450f8";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/.swapvol" =
    { device = "/dev/disk/by-uuid/d1e0b46b-68b9-4a9d-956c-2ae73b0450f8";
      fsType = "btrfs";
      options = [ "subvol=@swap" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D4D5-55D3";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [{
    device = "/.swapvol/swapfile";
    size = 16 * 1024;
  }];

  ## Hibernation

  # resumeDevice: set UUID of btrfs partition
  # kernelParams: $ sudo btrfs inspect-internal map-swapfile /.swapvol/swapfile
  boot.resumeDevice = "/dev/disk/by-uuid/d1e0b46b-68b9-4a9d-956c-2ae73b0450f8";
  boot.kernelParams = [ "resume_offset=533760" ];
  
  ## The rest:
  
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp46s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
