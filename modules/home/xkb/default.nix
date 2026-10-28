{ pkgs, pkgs-stable, mkFeature, ... }:

{
  imports = [
    (mkFeature "fcitx" "Enables fcitx5" {
      i18n.inputMethod = {
        type = "fcitx5";
        enable = true;
        fcitx5 = {
          # waylandFrontend = true;
          addons = with pkgs; [
            pkgs-stable.fcitx5-mozc
            fcitx5-fluent
            qt6Packages.fcitx5-configtool
            fcitx5-gtk
          ];
        };
      };

      home.file.".config/fcitx5/conf/classicui.conf".source =
        pkgs.writeText "classicui.conf" ''
          Theme=FluentDark-solid
        '';
    })
  ];
}
