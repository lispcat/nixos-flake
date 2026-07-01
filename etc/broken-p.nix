let
  broken-pkgs = [
    # "beets-copyartifacts"
    "beets-filetote"
  ];
  broken-predicate = nixpkgs: pkg:
    builtins.elem (nixpkgs.lib.getName pkg) broken-pkgs;
in
broken-predicate
