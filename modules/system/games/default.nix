{ pkgs, mkFeature, ... }:

{
  imports = [
    (mkFeature "games" "Enables steam and some games" {

      ## Steam #################################################

      programs.steam = {
        enable = true;
        package = pkgs.steam;
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extest.enable = true;
        localNetworkGameTransfers.openFirewall = false;
      };



      environment.etc = {
        "firejail/steam.profile".source = ./files/steam.profile;
      };
      programs.firejail.wrappedBinaries.steam = {
        executable = "${pkgs.steam}/bin/steam";
        # profile = "/etc/firejail/steam.profile";
        profile = "${pkgs.firejail}/etc/firejail/steam.profile";
      };
      programs.firejail.wrappedBinaries.steam-run = {
        executable = "${pkgs.steam}/bin/steam-run";
        # profile = "/etc/firejail/steam.profile";
        profile = "${pkgs.firejail}/etc/firejail/steam.profile";
      };



      ## Osu-Lazer #############################################

      environment.etc = {
        "firejail/osu-lazer.profile".text = ''
      # whitelist ~/./firejail/osulazer

      mkdir ~/.local/share/osu
      whitelist ~/.local/share/osu

      whitelist ~/.config

      ignore net none
      ignore no3d
      ignore nosound
      # TODO: What syscalls?
      ignore seccomp
      protocol unix,inet,inet6,netlink
      # include ~/.config/firejail/inc/firefox-escape.inc
      # include ~/.config/firejail/inc/discord-ipc.inc
      # include ~/.config/firejail/inc/default.inc
    '';
      };
      programs.firejail.wrappedBinaries."osu!" = {
        executable = "${pkgs.osu-lazer-bin}/bin/osu!";
        profile = "/etc/firejail/osu-lazer.profile";
      };
      environment.systemPackages = with pkgs; [
        osu-lazer-bin
      ];
    })
  ];
}
