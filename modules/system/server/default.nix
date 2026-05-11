{ pkgs, config, user, mkFeature, ... }:

let
  musicPath = "/home/${user}/Music/library/main";
in
{
  imports = [
    (mkFeature "navidrome" "Enable navidrome server" {
      services.navidrome = {
        enable = true;
        openFirewall = false;

        settings = {
          MusicFolder = musicPath;
          Address = "100.106.187.9";      # homelab tailscale local ip
          Port = 4533;
          BaseUrl = "";
          LogLevel = "info";

          ScanSchedule = "@every 1h";     # scan for new music
          TranscodingCacheSize = "500MB";
          SessionTimeout = "24h";
        };
      };
      # Make music directory accessible to navidrome
      systemd.services.navidrome.serviceConfig = {
        ReadOnlyPaths = [ musicPath ];
      };
      # Make navidrome user access files owned by other user
      users.users.navidrome.extraGroups = [ "users" ];
    })
  ];
}
