{ pkgs, ... }:

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
  ];
}
