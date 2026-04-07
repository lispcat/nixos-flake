{
  description = "My nix flake";

  ## Inputs:

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # Declarative user environment.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Real-time audio in NixOS.
    musnix.url = "github:musnix/musnix";

    # Run unpatched dynamic binaries
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    # LSP server to visualize ownership and lifetimes in Rust.
    rustowl-flake.url = "github:nix-community/rustowl-flake";

    # SMAPI stardew valley modding
    stardew-modding = {
      url = "github:Distracted-E421/stardew-modding-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  ## Outputs:

  outputs = { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      unfree-p = import ./etc/unfree-p.nix nixpkgs;

      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = unfree-p;
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfreePredicate = unfree-p;
      };

      # Boilerplate killer (hacky warning...)
      # Wraps `content` with stuff needed to add it to module system.
      # Returns an attrset. If other code outside scope of invocation,
      # may need to splice with inherit or separate then merge attrsets.
      mkFeature = name: desc: body:
        { config, lib, ... }: with lib; {
          options.features.${name}.enable =
            if desc != null
            then mkOption {
              type = types.bool;
            } else mkOption {
              type = types.bool;
              description = desc;
            };
          config = mkIf config.features.${name}.enable body;
        };

      # Function to create a system config.
      # Based on: https://github.com/sioodmy/dotfiles/blob/main/flake.nix
      mkSystem = { name, host, user, }:
        nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs user system pkgs-stable mkFeature;
          };
          modules = [
            # hostname
            { networking.hostName = host; }

            # system lib
            ./modules/system/default.nix

            # host settings (flags, hardware, pkgs)
            ./hosts/${name}/system/default.nix
          ];
        };

      # Function to create a home manager config.
      mkHome = { name, user }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs user system pkgs-stable mkFeature;
          };
          modules = [
            # home lib
            ./modules/home/default.nix

            # host settings (flags, hardware, pkgs)
            ./hosts/${name}/home/default.nix
          ];
        };
    in {
      # nixos outputs
      nixosConfigurations = {
        "laptop-sys" = mkSystem {
          name = "laptop";
          host = "NixOwOs";
          user = "sui";
        };
        "homelab-sys" = mkSystem {
          name = "homelab";
          host = "nixos";
          user = "rin";
        };
      };
      # home manager outputs
      homeConfigurations = {
        "laptop-home" = mkHome {
          name = "laptop";
          user = "sui";
        };
        "homelab-home" = mkHome {
          name = "homelab";
          user = "rin";
        };
      };
    };
}
