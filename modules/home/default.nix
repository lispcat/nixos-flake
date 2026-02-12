{ pkgs, inputs, user, mkFeature, ... }:

{
 # imports = [
  #   inputs.home-manager.nixosModules.home-manager
  # ];
  imports = [
    ./audio
    ./cron
    ./dev
    ./dotfiles
    ./shells
    ./themes
    ./xkb
    ./games
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    # Don't touch!
    stateVersion = "24.05";
  };

}
