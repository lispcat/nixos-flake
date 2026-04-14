{ mkFeature, pkgs, config, ... }:

{
  imports = [

    (mkFeature "wayland" "Enable generic wayland stuff" {
      environment.systemPackages = with pkgs; [
        wlsunset  # color temperature
        sway-contrib.grimshot  # screenshot
        bemenu  # dmenu replacement
        wbg  # minimal wallpaper daemon
        wl-clipboard-rs  # cli clipboard access
        # wmenu
        swaylock
        swayidle
        lswt
        xwayland
        waylock
        fuzzel      # app launcher
        waybar      # taskbar
        hyprpaper    # wallpapers
        hyprpicker   # color-picker
        hyprland-per-window-layout
      ];
    })

    # look into this later
    # https://github.com/sjcobb2022/nixos-config/blob/main/hosts/common/optional/greetd.nix
    (mkFeature "greetd" "Enable greetd (supports xorg and wayland)" {
      services.greetd = let
        sessionsPath =
          "${config.services.displayManager.sessionData.desktops}/share/xsessions:" +
          "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        tuigreetCommand =
          "${pkgs.tuigreet}/bin/tuigreet"
          + " --remember"
          + " --remember-user-session"
          + " --asterisks"
          + " --sessions ${sessionsPath}";
      in {
        enable = true;
        settings = {
          default_session = {
            command = tuigreetCommand;
            # "${pkgs.tuigreet}/bin/tuigreet --cmd " +
            # "'zsh -l -c river'";
          };
        };
        useTextGreeter = true;
      };
    })

    (mkFeature "river" "Enable riverwm" {
      environment.systemPackages = with pkgs; [
        river-classic
        wideriver
        sandbar
        # river
      ];

      programs.river-classic = {
        enable = true;
        xwayland.enable = true;
      };

      xdg.portal = {
        wlr.enable = true; # enables wlr portal
      };

      services.displayManager = let
        river-desktop-file =
          (pkgs.writeTextFile {
            name = "river-login-session";
            destination = "/share/wayland-sessions/river-login.desktop";
            text = ''
              [Desktop Entry]
              Name=River (Login Shell)
              Comment=Starts the River compositor inside a Zsh login shell
              Exec=zsh -l -c '${pkgs.river-classic}/bin/river 2>&1 | tee -a /tmp/river.log'
              Type=Application
            '';
          }).overrideAttrs (_: {
            passthru.providedSessions = [ "river-login" ];
          });
      in {
        sessionPackages = [
          river-desktop-file
        ];
      };

      security.pam.services = {
        swaylock.text = ''
          auth include login
        '';
        waylock.text = ''
          auth include login
        '';
      };
    })

    (mkFeature "hyprland" "Enable hyprland and greetd" {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };
      # services.greetd = {
      #   enable = true;
      #   settings.default_session.command =
      #     "${pkgs.tuigreet}/bin/tuigreet --cmd " +
      #     "'zsh -l -c Hyprland'";
      # };
      security.pam.services = {
        swaylock.text = ''
          auth include login
        '';
        waylock.text = ''
          auth include login
        '';
      };
    })

  ];
}

