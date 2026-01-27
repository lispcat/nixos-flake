{
  # System Flags

  features = {
    # global
    global.enable = true;

    # applications
    virtualization.enable = true;
    flatpak.enable = false;

    # firejail
    firejail.enable = true;

    # games
    games.enable = true;

    # hardware
    laptop-power.enable = true;

    # misc
    nix-ld.enable = false;

    # networking
    mullvad.enable = false;
    bluetooth.enable = false;
    dns-over-https.enable = false;

    # renoise
    renoise.enable = true;

    # wayland
    hyprland.enable = true;
    # hyprland.enable = false;
    # river.enable = false;
    river.enable = true;

    # zsh
    zsh.enable = true;
  };
}
