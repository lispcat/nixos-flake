{ user, lib, pkgs, config, mkFeature, ... }:

{
  imports = [

    ### Navidrome ###

    (let
      musicHome = "/mnt/music";
      musicPath = "/mnt/music/main";
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
          };
        };
        systemd.services.navidrome.serviceConfig = {
          # env vars
          EnvironmentFile = "/etc/secrets/navidrome.env";
          # for extra security
          ReadOnlyPaths = [ musicPath ];
        };
        users.users.navidrome.extraGroups = [ "users" ];

        # TODO: maybe needed, in case broken imports?
        # Continuously fix perms on all files in music dir
        systemd.services.music-permission-fix = {
          description = "Fix music library group permissions";
          script = ''
            chown -R ${user}:users ${musicHome}
            chmod -R u=rwX,g=rX,o= ${musicHome}
          '';
          serviceConfig.Type = "oneshot";
        };
        systemd.timers.music-permission-fix = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*-*-* 09:00:00";
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
        wants = [ "network-online.target" ];

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

    ### slskdN(OT)

    (mkFeature "slskdn" "Enable slskdN server" {
      environment.etc."slskdn/docker-compose.yml".source =
        ./slskdn/docker-compose.yml;

      systemd.services.slskdn = {
        description = "slskdN soulseek daemon";
        after    = [ "docker.service" "network-online.target" "vpn-proxy.service" ];
        requires = [ "docker.service" ];
        wants    = [ "network-online.target" "vpn-proxy.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type            = "oneshot";
          RemainAfterExit = true;
          WorkingDirectory = "/etc/slskdn";
          EnvironmentFile  = "/etc/secrets/slskdn.env";
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
          ExecStop  = "${pkgs.docker-compose}/bin/docker-compose down";
        };
      };
    })

    ### slskd ###

    (let
      src-path = "/mnt/music/main";
      dl-path = "/mnt/music/downloaded";
    in
      mkFeature "slskd" "Enable slskd server" {
        services.slskd = {
          enable = true;
          environmentFile = "/etc/secrets/slskd.env"; # username & pass
          settings = {
            soulseek = {
              connection.proxy = {
                enabled = true;
                address = "127.0.0.1";
                port    = 1080;
              };
            };
            shares.directories  = [ src-path ];
            downloads.directory = dl-path;
          };
        };
        systemd.services.slskd.serviceConfig = {
          # extra security
          ReadOnlyPaths = [ src-path ];
          ReadWritePaths = [ dl-path ];
        };
        users.users.slskd.extraGroups = [ "users" ];
      })

  ];
}
