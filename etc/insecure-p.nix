let
  insecure-pkgs = [
    "librewolf-151.0.2-1"
  ];
  insecure-predicate = nixpkgs: pkg:
    builtins.elem (nixpkgs.lib.getName pkg) insecure-pkgs;
in
insecure-predicate
