{ mkFeature, pkgs, ... }:

{
  imports = [
    (mkFeature "hyprland" "Enable hyprland and greetd" {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };
      # portals (no need for wlr, hyprland come with special)
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
      services.greetd = {
        enable = true;
        settings.default_session.command =
          "${pkgs.tuigreet}/bin/tuigreet --cmd " +
          "'zsh -l -c Hyprland'";
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
    (mkFeature "river" "Enable riverwm" {
      programs.river-classic = {
        enable = true;
        xwayland.enable = true;
      };
      # set up portals
      xdg.portal = {
        enable = true;
        wlr.enable = true; # enables wlr portal
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };
      # services.greetd = {
      #   enable = true;
      #   settings.default_session.command =
      #     "${pkgs.tuigreet}/bin/tuigreet --cmd " +
      #     "'zsh -l -c river'";
      # };
      # security.pam.services = {
      #   swaylock.text = ''
      #     auth include login
      #   '';
      #   waylock.text = ''
      #     auth include login
      #   '';
      # };
    })
  ];
}

