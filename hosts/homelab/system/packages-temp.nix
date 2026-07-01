{ inputs, pkgs, pkgs-stable, ... }:

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
          propagatedBuildInputs = [ python314Packages.beets-filetote ];
        };
      };
    })

    nicotine-plus
    kid3

    ### Scripts ###
    (python313.withPackages (ps: [
      ps.prompt-toolkit
    ]))
  ];
}
