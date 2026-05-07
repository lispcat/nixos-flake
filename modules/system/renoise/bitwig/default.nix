{ pkgs, lib, ... }:

let
  bitwig-deb = pkgs.requireFile {
    name = "bitwig-studio-6.0.deb";
    sha256 = "sha256-artZcqN95SxxguB0xUm0qG7c6uwbhJEQrcR9OuLQowk=";
    message = ''
      Bitwig deb file not found in Nix Store.

      1. Locate bitwig-studio-xxx.deb
      2. Add to the store:
         nix-store --add-fixed sha256 /path/to/your/bitwig-studio-xxx.deb
    '';
  };
  bitwig-pkgbuild = ./package.nix;

  bitwig-studio-custom = pkgs.callPackage bitwig-pkgbuild {
    src = bitwig-deb;
  };

  bitwig-tweaked = lib.pipe bitwig-studio-custom [
    (it: it.overrideAttrs
      (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [
          pkgs.steam-run-free
        ];
      })
    )
    (it:
      let
        steam-run = "${pkgs.steam-run-free}/bin/steam-run";
        binary = "${it}/bin/bitwig-studio";
      in
        # pkgs.writeShellScriptBin "renoise" ''
        #   exec ${unshare} -- ${steam-run} ${renoise} "$@"
        # ''
        pkgs.writeShellScriptBin "renoise" ''
          exec ${steam-run} ${binary} "$@"
        ''
    )
  ];
in
bitwig-tweaked
