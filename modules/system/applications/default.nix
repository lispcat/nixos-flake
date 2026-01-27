{ config, pkgs, user, mkFeature, ... }:

{
  imports = [
    (mkFeature "virtualization" "Enables virtualization" {
      virtualisation.libvirtd = {
        enable = true;
        qemu.package = pkgs.qemu_kvm;
      };
      users.users.${user}.extraGroups = [ "libvirtd" "docker" ];

      # TODO: move this into its own module
      virtualisation.docker = {
        enable = true;
        storageDriver = "btrfs";
      };
      environment.systemPackages = with pkgs; [
        docker-compose
      ];

    })
    (mkFeature "flatpak" "Enables flatpak" {
      services.flatpak.enable = true;
      systemd.services.flatpak-repo = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        '';
      };
    })
  ];
}
