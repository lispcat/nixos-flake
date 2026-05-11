{ pkgs, lib, ... }:

# NOTE: requires --impure flag when rebuild.

let
  # bitwig-deb = pkgs.requireFile {
  #   name = "bitwig-studio-6.0.deb";
  #   sha256 = "sha256-jrCTgaxfeWhfKwLeKLmqTQWS7RVbVnHqJ0InCipmm8k=";
  #   message = ''
  #     Bitwig deb file not found in Nix Store.

  #     1. Add to the store:
  #        nix-store --add-fixed sha256 /path/to/your/bitwig-studio-xxx.deb
  #     2. Verify hash:
  #        nix hash file --sri /path/to/your/bitwig-studio-xxx.deb
  #   '';
  # };

  bitwig-jar-file = pkgs.requireFile {
    name = "bitwig.jar";
    # sha256 = "sha256-KujZU3h1/OluU8QxPR/QPlz2wS1j3lS5Wxj8zBvKWLQ=";
    sha256 = "sha256-1A8IZNBnwt5odlml7jxRE1YMZXX9arR874uYdl7M6JA=";
    message = ''
      Bitwig jar file not found in Nix Store.

      1. Add to the store:
         nix-store --add-fixed sha256 /path/to/your/bitwig.jar
      3. Verify hash:
         nix hash file --sri /path/to/your/bitwig.jar
    '';
  };

  bitwig-pkgbuild = ./package.nix;

  bitwig-custom = (pkgs.callPackage bitwig-pkgbuild {})
    .overrideAttrs (oldAttrs: {
      # src = bitwig-deb; # custom deb
      buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.steam-run-free ];
      postFixup = (oldAttrs.postFixup or "") + ''
        rm $out/libexec/bin/bitwig.jar
        ln -s /home/sui/opt/bitwig/bitwig.jar $out/libexec/bin/bitwig.jar
      '';
      # postFixup = (oldAttrs.postFixup or "") + ''
      #   cp ${bitwig-extra-file} $out/bin/myscript.jar
      #   chmod +x $out/bin/myscript.jar
      # '';
    });

  bitwig-tweaked =
    let
      steam-run = "${pkgs.steam-run-free}/bin/steam-run";
      binary = "${bitwig-custom}/bin/bitwig-studio";
    in
      pkgs.writeShellScriptBin "bitwig-studio" ''
        exec ${steam-run} ${binary} "$@"
      '';
in
bitwig-tweaked
