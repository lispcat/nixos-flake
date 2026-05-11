{
  # don't touch
  system.stateVersion = "24.05";

  # TODO: make it auto-import all dirs!

  imports = [
    ./global.nix

    ./applications
    ./firejail
    ./games
    ./hardware
    ./misc
    ./server
    ./networking
    ./renoise
    ./shells
    ./wayland
    ./xorg
  ];
}
