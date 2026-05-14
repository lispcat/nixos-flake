{ lib, pkgs, config, user, mkFeature, ... }:

{
  imports = [
    (let
      musicPath = "/home/${user}/Music/library/main";
    in
      mkFeature "navidrome" "Enable navidrome server" {
        services.navidrome = {
          enable = true;
          openFirewall = false;

          settings = {
            MusicFolder = musicPath;
            Address = "homelab";      # homelab tailscale local ip
            Port = 4533;
            BaseUrl = "";
            LogLevel = "info";

            ScanSchedule = "@every 30m";     # scan for new music
            TranscodingCacheSize = "500MB";
            SessionTimeout = "24h";

            # TODO: move secret from hard path to sops
            LastFM.ApiKey = builtins.readFile /etc/secrets/lastfm-api.key;
            LastFM.Secret = builtins.readFile /etc/secrets/lastfm-secret.key;
          };
        };

        # Make music directory accessible to navidrome
        systemd.services.navidrome.serviceConfig = {
          ReadOnlyPaths = [ musicPath ];
          ProtectHome = lib.mkForce "read-only";
        };
        users.users.navidrome.extraGroups = [ "users" ];

        # Continuously fix perms on all files in music dir
        systemd.services.music-permission-fix = {
          description = "Fix music library group permissions";
          script = ''
            chmod -R g+rX ${musicPath}
          '';
          serviceConfig.Type = "oneshot";
        };
        systemd.timers.music-permission-fix = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*-*-* *:00,30:00";
            Persistent = true;  # runs on next boot if it missed its window
          };
        };
      })
  ];
}
