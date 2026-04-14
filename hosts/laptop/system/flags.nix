{
  # System Flags

  features = {
    # global
    global.enable = true;

    # applications
    virtualization.enable = true;
    flatpak.enable = true;

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
    dns-over-https.enable = true;
    sshd.enable = false;
    tailscale.enable = true;

    # renoise
    renoise.enable = true;

    # desktop
    greetd.enable = true;

    # wayland
    wayland.enable = false;
    river.enable = false;
    hyprland.enable = false;

    # xorg
    xorg.enable = true;
    xmonad.enable = true;

    # zsh
    zsh.enable = true;

    # vpn proxy for p2p
    vpn-proxy.enable = false; # broken, using docker-compose till SOPS
  };
}
