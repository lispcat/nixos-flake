{ inputs, pkgs, pkgs-stable, ... }:

let
  beets-filetote-custom = pkgs-stable.callPackage ./packages/beets-filetote.nix {};
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    ### Basic ###

    home-manager
    vim
    git
    tree
    emacs
    fzf
    fd
    tmux
    unzip
    trash-cli
    neovim
    alacritty
    mpv
    btop
    htop
    glances
    nethogs
    ffmpeg
    yt-dlp
    croc
    exiftool
    ripgrep
    tldr
    cmake
    gnumake
    # findutils
    xauth # needed for x11 forwarding?

    ### Applications ###

    librewolf
    kdePackages.dolphin # good default

    ### X utils ###

    xdg-utils # for xdg-mime

    ### Code ###

    cargo

    ### Music ###

    sshfs
    picard
    chromaprint
    ## beets custom
    (pkgs-stable.python314Packages.beets.override {
      pluginOverrides = {
        filetote = {
          enable = true;
          propagatedBuildInputs = [ beets-filetote-custom ];
        };
      };
    })
    spek
    nicotine-plus
    kid3
    losslessaudiochecker
    flac

    ### Scripts ###
    (python313.withPackages (ps: [
      ps.prompt-toolkit
    ]))

    ### MC ###

    rcon-cli

  ];
}
