{ mkFeature, pkgs, pkgs-stable, ... }:

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
      # enable bitmap fonts on xorg
      fonts.fontDir.enable = true;

      # Xorg packages
      environment.systemPackages = with pkgs; [
        (haskellPackages.ghcWithPackages (ps: [
          ps.xmonad ps.xmonad-contrib
        ]))
        trayer
        xmobar
        xmessage
        scrot
        xscreensaver
        xfce4-power-manager
        picom
        dunst
        xclip
        dmenu-rs
        pkgs-stable.kbdd
        rofi
        xkb-switch
        screenkey
      ];
    })

    (mkFeature "xmonad" "Enable xmonad" {
      environment.systemPackages = with pkgs; [
        (haskellPackages.ghcWithPackages (ps: [
          ps.xmonad ps.xmonad-contrib
        ]))
      ];
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
