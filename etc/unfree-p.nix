let
  unfree-pkgs = [
    # music
    "vital"
    "spotify"
    "renoise"
    "renoise-custom"
    "rns_354_linux_x86_64.tar.gz"
    "reaper"
    "vcv-rack"
    "rave-generator-2"
    "sunvox"
    "bitwig-studio"
    "bitwig-studio6"
    "bitwig-studio-unwrapped"
    "losslessaudiochecker"

    # games
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
    "osu-lazer-bin"

    # other
    "zpix-pixel-font"
  ];
  unfree-predicate = nixpkgs: pkg:
    builtins.elem (nixpkgs.lib.getName pkg) unfree-pkgs;
in
unfree-predicate
