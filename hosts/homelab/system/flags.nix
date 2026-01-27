{
  # System Flags

  # (no need to specify config prefix, because that's the
  # final state of the ENTIRE flake config)

  features = {
    ## Global
    global.enable = true;
    ## Applications
    virtualization.enable = false;
    flatpak.enable = false;
    ## Firejail
    firejail.enable = true;
    ## Games
    games.enable = true;
    ## Hardware
    laptop-power.enable = false;
    ## Misc
    nix-ld.enable = false;
    ## Networking
    mullvad.enable = false;
    bluetooth.enable = false;
    dns-over-https.enable = false;
    ## Renoise
    renoise.enable = false;
    ## Wayland
    hyprland.enable = true;
    river.enable = true;
    ## Zsh
    zsh.enable = true;
  };
}
