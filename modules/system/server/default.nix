{ inputs, system, user, lib, pkgs, config, mkFeature, ... }:

{
  imports = [

    ### Navidrome ###

    (let
      musicHome = "/mnt/audio/shared";
      musicPath = "/mnt/audio/shared/music";
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
            chmod -R u=rwX,g=rwX,o= ${musicHome}
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

    ### Nicotine + vpn ###

    # note: if having any issues, try
    # `sudo docker rmi nicotine-vpn-nicotine 2>/dev/null`
    (mkFeature "nicotine-vpn" "Enable nicotine + vpn proxy" {
      environment.etc."nicotine-vpn/docker-compose.yml".source =
        ./nicotine-vpn/docker-compose.yml;
      environment.etc."nicotine-vpn/Dockerfile".source =
        ./nicotine-vpn/Dockerfile;

      systemd.services.nicotine-vpn = {
        description = "nicotine daemon + vpn";
        after    = [ "docker.service" "network-online.target" ];
        requires = [ "docker.service" ];
        wants    = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type             = "oneshot";
          RemainAfterExit  = true;
          WorkingDirectory = "/etc/nicotine-vpn";
          EnvironmentFile  = "/etc/secrets/nicotine-vpn.env";
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
          ExecStop  = "${pkgs.docker-compose}/bin/docker-compose down";
        };
      };
      networking.firewall.allowedTCPPorts = [ 6080 6081 ]; # VNC ports
    })

    ### Minecraft server + vpn ###

    (mkFeature "minecraft-vpn" "Enable minecraft server + vpn proxy" {
      # custom user
      users.groups.mcserver = {
        gid = 4440;
      };

      users.users.mcserver = {
        isSystemUser = true;
        group = "mcserver";
        uid = 4440;
        description = "Minecraft docker stack";
        home = "/var/empty";
        createHome = false;
      };

      systemd.tmpfiles.rules = [
        "L+ /var/lib/minecraft-vpn/docker-compose.yml - - - - ${./minecraft-vpn/docker-compose.yml}"
      ];

      systemd.services.minecraft-vpn = {
        description = "minecraft server + vpn";
        after    = [ "docker.service" "network-online.target" ];
        requires = [ "docker.service" ];
        wants    = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type             = "oneshot";
          RemainAfterExit  = true;
          WorkingDirectory = "/var/lib/minecraft-vpn";
          EnvironmentFile  = "/etc/secrets/minecraft-vpn.env";
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
          ExecStop  = "${pkgs.docker-compose}/bin/docker-compose down";
          Restart    = "on-failure";
          RestartSec = "10s";

          # hardening the compose process (hopefully wont break anything)
          NoNewPrivileges = true;
          CapabilityBoundingSet = "";
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ "/var/lib/minecraft-vpn" ];
          PrivateTmp = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
          RestrictNamespaces = true;
        };
      };
      # networking.firewall.allowedTCPPorts = [ 25565 ]; # no need anymore
    })

    ### slskdN(OT) + vpn

    (mkFeature "slskdn-vpn" "Enable slskdN + vpn proxy" {
      environment.etc."slskdn-vpn/docker-compose.yml".source =
        ./slskdn-vpn/docker-compose.yml;
      environment.etc."slskdn-vpn/Dockerfile".source =
        ./slskdn-vpn/Dockerfile;
      # environment.etc."slskdn-vpn/config".source =
      #   ./slskdn-vpn/config;
      # environment.etc."slskdn-vpn/gluetun-auth.toml".source =
      #   /etc/secrets/gluetun-auth.toml;

      systemd.services.slskdn-vpn = {
        description = "slskdN soulseek daemon + vpn";
        after    = [ "docker.service" "network-online.target" ];
        requires = [ "docker.service" ];
        wants    = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        # prepare the writable directory for slskd.yml
        preStart = ''
          # Ensure target directory exists and has reasonable permissions
          ${pkgs.coreutils}/bin/mkdir -p /var/lib/slskdn-vpn/config
          # Copy initial config file from Nix source into the writable location
          ${pkgs.coreutils}/bin/cp -f ${./slskdn-vpn/config/slskd.yml} /var/lib/slskdn-vpn/config/slskd.yml
        '';
        serviceConfig = {
          Type             = "oneshot";
          RemainAfterExit  = true;
          WorkingDirectory = "/etc/slskdn-vpn";
          EnvironmentFile  = "/etc/secrets/slskdn-vpn.env";
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
          ExecStop  = "${pkgs.docker-compose}/bin/docker-compose down";
        };
      };
      networking.firewall.allowedTCPPorts = [ 5030 50300 ];
    })

    ### VPN Proxy ###

    (mkFeature "vpn-proxy" "Enable per-app vpn proxy" {
      # copy docker-compose.yml into store
      environment.etc."vpn-proxy/docker-compose.yml".source =
        ./vpn-proxy/docker-compose.yml;

      # as systemd service
      systemd.services.vpn-proxy = {
        description = "Socks5 vpn proxy";
        after    = [ "docker.service" "network-online.target" ]; # start after docker + network
        requires = [ "docker.service" ];
        wants    = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ]; # autostart on boot

        serviceConfig = {
          Type             = "oneshot";  # keep service running after process exits
          RemainAfterExit  = true;  # keeps service active after exit
          WorkingDirectory = "/etc/vpn-proxy";  # path to docker-compose.yml
          EnvironmentFile  = "/etc/secrets/vpn-laptop.env";  # path to env file
          ExecStart        = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
          ExecStop         = "${pkgs.docker-compose}/bin/docker-compose down";
        };
      };
    })

    ### slskdN(OT)

    (mkFeature "slskdn" "Enable slskdN server" {
      environment.etc."slskdn/docker-compose.yml".source =
        ./slskdn/docker-compose.yml;
      environment.etc."slskdn/slskdn.yml".source =
        ./slskdn/slskdn.yml;

      systemd.services.slskdn = {
        description = "slskdN soulseek daemon";
        after    = [ "docker.service" "network-online.target" "vpn-proxy.service" ];
        requires = [ "docker.service" ];
        wants    = [ "network-online.target" "vpn-proxy.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type             = "oneshot";
          RemainAfterExit  = true;
          WorkingDirectory = "/etc/slskdn";
          EnvironmentFile  = "/etc/secrets/slskdn.env";
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
          ExecStop  = "${pkgs.docker-compose}/bin/docker-compose down";
        };
      };
      networking.firewall.allowedTCPPorts = [ 5030 50300 61241 ];
    })

    ### slskd ###

    (let
      src-path = "/mnt/music/main";
      dl-path = "/mnt/music/downloads";
      inc-path = "/mnt/music/incomplete";
    in
      mkFeature "slskd" "Enable slskd server" {
        services.slskd = {
          # package = inputs.slskdn.packages.${pkgs.system}.default;
          enable = true;
          environmentFile = "/etc/secrets/slskdn.env";
          group = "users";

          settings = {
            # network.address = "";
            # network.port = 5030;
            web.address = "0.0.0.0";  # needed for web ui

            soulseek = {
              # listen_port = 61241;  # port forwarded port
              connection.proxy = {
                enabled = true;
                address = "0.0.0.0";
                port    = 1080;
              };
            };
            shares.directories  = [ src-path ];
            directories.downloads = dl-path;
            directories.incomplete = inc-path;
          };
        };
        systemd.services.slskd.serviceConfig = {
          ReadOnlyPaths = [ src-path ];
          ReadWritePaths = [ dl-path inc-path ];
        };
        # not the solution
        # systemd.services.slskd.environment = {
        #   ALL_PROXY = "socks5://127.0.0.1:1080";
        #   all_proxy = "socks5://127.0.0.1:1080";
        # };
        users.users.slskd.extraGroups = [ "users" ];
      })

  ];
}
