{ user, pkgs, config, mkFeature, ... }:

{
  imports = [
    (mkFeature "mpd" "Enable mpd service" {
      home.packages = with pkgs; [ mpc ];
      services = {
        # use 'systemctl --user' to interact
        mpd = {
          enable = true;
          # considering changing config.xdg.userDirs.music directly?
          musicDirectory =
            "${config.home.homeDirectory}/Music/library";
          extraConfig = ''
            # prevent mpd from suddenly resuming
            restore_paused    "yes"

            # pipewire output
            audio_output {
              type "pipewire"
              name "My PipeWire output"
            }
          '';
        };
        mpdris2 = {
          enable = true;
          multimediaKeys = true;
          notifications = true;
        };
        # mpdscribble = {
        #   enable = true;
        #   endpoints = {
        #     "last.fm" = {
        #       username = "window010101";
        #       # TODO: requires SOPS (is pretty easy)
        #       # https://github.com/Serpentian/AlfheimOS/blob/master/system/security/sops.nix
        #       # passwordFile = "/run/secrets/lastfm";
        #     };
        #   };
        # };
      };
    })
    (mkFeature "pro-audio" "Setup for music production" {
      home.file = {
        ".config/yabridgectl/config.toml".text = ''
          plugin_dirs = [
            '/home/${user}/.win-vst',
            '/home/${user}/.wine/drive_c/Program Files/Common Files/VST3',
            '/home/${user}/.wine/drive_c/Program Files/Steinberg/VstPlugins'
          ]
          vst2_location = 'centralized'
          no_verify = false
          blacklist = []

          [vst2]
          editor_force_dnd = false
          editor_disable_host_scaling = true
        '';
      };
    })
  ];
}
