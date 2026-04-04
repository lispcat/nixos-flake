{
  # System Flags

  # (no need to specify config prefix, because that's the
  # final state of the ENTIRE flake config)

  features = {
    # global
    global.enable = true;

    # applications
    virtualization.enable = false;
    flatpak.enable = false;
    # flatpak.enable = true;

    # firejail
    firejail.enable = true;

    # games
    games.enable = false;

    # hardware
    laptop-power.enable = false;

    # misc
    nix-ld.enable = false;

    # networking
    mullvad.enable = false;
    bluetooth.enable = false;
    dns-over-https.enable = true;
    sshd.enable = true;
    tailscale.enable = true;

    # renoise
    renoise.enable = false;

    # desktop
    greetd.enable = true;

    # wayland
    # hyprland.enable = true;
    hyprland.enable = false;
    river.enable = false;
    # river.enable = true;

    # xorg
    xorg.enable = true;
    xmonad.enable = false;

    # zsh
    zsh.enable = true;

    # vpn proxy for p2p
    vpn-proxy.enable = false; # broken, using docker-compose till SOPS
  };
}
