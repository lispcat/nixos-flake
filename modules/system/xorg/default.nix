{ mkFeature, pkgs, ... }:

{
  imports = [

    (mkFeature "xorg" "Enable xorg" {
      services.xserver = {
        enable = true;
        displayManager.startx.enable = true;
      };
      services.libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          disableWhileTyping = true;
          tappingDragLock = false;
        };
      };
      services.touchegg.enable = true;
      # environment.systemPackages = with pkgs; [
      #   libinput-gestures xdotool wmctrl
      # ];
    })

    (mkFeature "xmonad" "Enable xmonad" {
      services.xserver.windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: [
          haskellPackages.dbus
          haskellPackages.List
          haskellPackages.monad-logger
        ];
      };

      services.displayManager = let
        desktop-file =
          (pkgs.writeTextFile {
            name = "xmonad-login-session";
            destination = "/share/xsessions/xmonad-login.desktop";
            text = ''
              [Desktop Entry]
              Name=Xmonad (Login Shell)
              Comment=Starts the Xmonad WM inside a Zsh login shell
              Type=XSession
              Exec=zsh -l -c 'startx ${pkgs.haskellPackages.xmonad}/bin/xmonad 2>&1 | tee -a /tmp/xmonad.log'
            '';
          }).overrideAttrs (_: {
            passthru.providedSessions = [ "xmonad-login" ];
          });
      in {
        sessionPackages = [
          desktop-file
        ];
      };
    })
  ];
}
