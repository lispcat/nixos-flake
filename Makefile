default: laptop-all-fancy

update:
	nix flake update

## laptop ##

automount-handle:
	sudo systemctl stop home-sui-Music-homelab.automount || true
	sudo systemctl stop home-sui-Music-homelab.mount || true

laptop-sys: automount-handle
	sudo nixos-rebuild switch --flake .#laptop-sys --impure

laptop-sys-build: automount-handle
	sudo nixos-rebuild build --flake .#laptop-sys --impure

laptop-home:
	home-manager switch --flake .#laptop-home --impure

laptop-home-build:
	home-manager build --flake .#laptop-home --impure

laptop-all: laptop-sys laptop-home

laptop-all-fancy:
	sudo true && sudo nixos-rebuild switch --flake .#laptop-sys --impure |& nom
	home-manager switch --flake .#laptop-home --impure |& nom
	sudo nix-channel --update
	nix-env -u '*'

## Homelab ##

homelab-sys:
	sudo nixos-rebuild switch --flake .#homelab-sys --impure

homelab-sys-build:
	sudo nixos-rebuild build --flake .#homelab-sys --impure

homelab-home:
	home-manager switch --flake .#homelab-home --impure

homelab-home-build:
	home-manager build --flake .#homelab-home --impure

homelab-all: homelab-sys homelab-home

homelab-all-fancy:
	sudo true && sudo nixos-rebuild switch --flake .#homelab-sys --impure |& nom
	home-manager switch --flake .#homelab-home --impure |& nom
	sudo nix-channel --update
	nix-env -u '*'

## Misc ##

env:
	sudo nix-channel --update
	nix-env -u '*'

all: update env laptop-sys laptop-sys-build laptop-home laptop-home-build laptop-all laptop-all-fancy homelab-sys homelab-sys-build homelab-home homelab-home-build homelab-all homelab-all-fancy

.PHONY: default update sys home env
