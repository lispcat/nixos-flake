{ lib, pkgs, config, user, mkFeature, ... }:

{
  imports = [

    ### Navidrome ###

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
            # LastFM.ApiKey = builtins.readFile /etc/secrets/lastfm-api.key;
            # LastFM.Secret = builtins.readFile /etc/secrets/lastfm-secret.key;
          };
        };

        # Environment vars
        systemd.services.navidrome.serviceConfig = {
          EnvironmentFile = "/etc/secrets/navidrome.env";
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

    ### VPN Proxy ###

    (mkFeature "vpn-proxy" "Enable per-app vpn proxy" {
      # copy docker-compose.yml into store
      environment.etc."vpn-proxy/docker-compose.yml".source =
        ./vpn-proxy/docker-compose.yml;

      # as systemd service
      systemd.services.vpn-proxy = {
        description = "Socks5 vpn proxy";
        # start after docker is running and network is up
        after = [ "docker.service" "network-online.target" ];
        requires = [ "docker.service" ];

        # autostart on boot
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          # oneshot: keep service running after process exits
          # RemainAfterExit keeps service active after exit
          Type = "oneshot";
          RemainAfterExit = true;

          # WorkingDirectory defines path to docker-compose.yml
          # EnvironmentFile defines path to env file
          WorkingDirectory = "/etc/vpn-proxy";
          EnvironmentFile = "/etc/secrets/vpn.env";

          # start containers, clean up old runs
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
          # stop containers on `systemctl stop` or shutdown
          ExecStop  = "${pkgs.docker-compose}/bin/docker-compose down";
        };
      };
    })

  ];
}
