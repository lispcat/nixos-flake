{ inputs, pkgs, user, mkFeature, ... }:

{
  imports = [
    (mkFeature "global" "Default system config for all hosts" {

      ## User ##############################################

      users = {
        users.${user} = {
          isNormalUser = true;
          description = "${user}";
          extraGroups = [ "wheel" "networkmanager" "audio" "wireshark" "input" ];
        };
      };

      ## Keyboard ##########################################

      services.xserver.xkb = {
        layout = "us";
        variant = "dvp";
        options = "ctrl:nocaps,grp:menu_toggle";  # different for wayland comp
      };
      console = {
        useXkbConfig = true;
        earlySetup = true;  # for grub?
      };

      ## Locale ############################################

      # Set your time zone.
      time.timeZone = "America/New_York";

      # Select internationalisation properties.
      i18n = {
        defaultLocale = "en_US.UTF-8";

        extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };
      };

      ## Networking ########################################

      networking.networkmanager.enable = true;
      networking.networkmanager.plugins = with pkgs; [
        networkmanager-openvpn
      ];

      ## Audio #############################################

      services.pipewire = {
        enable = true;

        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      security.rtkit.enable = true;

      ## Applications ######################################

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk # TODO: change this to another?
        ];
        config.common.default = "*";
      };

      ## Linux #############################################

      # polkit (dont really know what this does)
      security.polkit.enable = true;

      # some programs depend on it i think
      services.dbus.enable = true;

      # mounting disks
      services.udisks2.enable = true;

      boot = {
        tmp.cleanOnBoot = true;
      };

      ## NixOS #############################################

      nix = {
        settings = {
          trusted-users = [ "root" "${user}" ];
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
          keep-failed = true;
          download-buffer-size = 524288000;
        };
        # auto-gc every week
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };

      ## Misc ##############################################

      programs.dconf.enable = true;
    })
  ]; }
