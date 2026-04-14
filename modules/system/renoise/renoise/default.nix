{ pkgs, lib, ... }:

# TODO:
# - Turn this into a reusable function, where it takes a package,
#   changes hash, sets path to installer, etc, and finally
#   returns a new modified package.
#   Allow for easy multiple renoise installs.

let
  renoise-src = pkgs.requireFile {
    # name = "rns_344_linux_x86_64.tar.gz";
    # name = "rns_353_linux_x86_64.tar.gz";
    name = "rns_354_linux_x86_64.tar.gz";

    ### Paste hash from `nix hash file <tarball>`.
    # sha256 = "sha256-Kl7iLMDZdpxaodIfW+JdOjgdN7/vUKx4uhWr2bEsECo=";
    # sha256 = "sha256-Sr9UffECVm/E1F5kP4kog0swB22qYedqXNSQFclZiBI=";
    sha256 = "sha256-artZcqN95SxxguB0xUm0qG7c6uwbhJEQrcR9OuLQowk=";
    message = ''
      Renoise tarball not found in Nix Store.

      1. Locate rns_XXX_linux_x86_64.tar.gz
      2. Add to the store:
         nix-store --add-fixed sha256 /path/to/your/rns_XXX_linux_x86_64.tar.gz
    '';
  };
  # renoise-pkg-path = ./renoise-344.nix;
  # renoise-pkg-path = ./renoise-353.nix;
  renoise-pkg-path = ./renoise-354.nix;

  renoise-pkg = pkgs.callPackage renoise-pkg-path {
    # custom tarball installer
    releasePath = renoise-src;
  };

  renoise-custom = lib.pipe renoise-pkg [
    # runtime dependencies
    (rns: rns.overrideAttrs
      (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [
          pkgs.steam-run-free
        ];
      })
    )
    # wrap in FHS sandbox with no internet
    (rns:
      let
        # unshare = "${pkgs.util-linux}/bin/unshare -r -n";
        steam-run = "${pkgs.steam-run-free}/bin/steam-run";
        renoise = "${rns}/bin/renoise";
      in
        # pkgs.writeShellScriptBin "renoise" ''
        #   exec ${unshare} -- ${steam-run} ${renoise} "$@"
        # ''
        pkgs.writeShellScriptBin "renoise" ''
          exec ${steam-run} ${renoise} "$@"
        ''
    )
  ];
in
renoise-custom
