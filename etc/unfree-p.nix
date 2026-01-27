let
  unfree-pkgs = [
    # music
    "vital"
    "spotify"
    "renoise"
    "reaper"
    "vcv-rack"
    "rave-generator-2"
    "sunvox"
    "bitwig-studio"
    "bitwig-studio-unwrapped"

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
