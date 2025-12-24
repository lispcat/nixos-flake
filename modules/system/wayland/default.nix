{ mkFeature, pkgs, ... }:

{
  imports = [
    (mkFeature "hyprland" "Enable hyprland and greetd" {
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
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    })
    (mkFeature "river" "Enable riverwm" {
      # services.greetd = {
      #   enable = true;
      #   settings.default_session.command =
      #     "${pkgs.tuigreet}/bin/tuigreet --cmd " +
      #     "'zsh -l -c Hyprland'";
      # };
      # security.pam.services = {
      #   swaylock.text = ''
      #     auth include login
      #   '';
      #   waylock.text = ''
      #     auth include login
      #   '';
      # };
      programs.river-classic = {
        enable = true;
        xwayland.enable = true;
      };
    })
  ];
}

