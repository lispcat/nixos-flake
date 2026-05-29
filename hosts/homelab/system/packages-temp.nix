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

    ### Applications ###

    librewolf
    kdePackages.dolphin # good default

    ### X utils ###

    xdg-utils # for xdg-mime

    ### Music ###

    sshfs
    picard
    chromaprint
    python314Packages.beets
    # python314Packages.beets-copyartifacts
    nicotine-plus

    ### Scripts ###
    (python313.withPackages (ps: [
      ps.prompt-toolkit
    ]))
  ];
}
