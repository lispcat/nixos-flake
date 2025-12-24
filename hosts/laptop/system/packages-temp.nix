{ pkgs, pkgs-stable, ... }:

let
  base-emacs = pkgs.emacs30-pgtk;
  emacs-with-pkgs =
    (pkgs.emacsPackagesFor base-emacs).emacsWithPackages (epkgs: [
      epkgs.vterm
      epkgs.jinx
    ]);
  tex-custom = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-basic
      dvisvgm dvipng # for preview and export as html
      wrapfig amsmath ulem hyperref capt-of
      preview newunicodechar cm-super fontspec
      unicode-math lualatex-math xits mathtools enumitem
      preprint minted upquote lineno underscore;
  });
in {

  environment.systemPackages = with pkgs; [

    ### Custom ######################################################

    emacs-with-pkgs
    tex-custom

    ## Emacs dependencies
    w3m  # for w3m
    latexminted # for org export code coloring
    emacs-lsp-booster

    ### Basic #######################################################

    home-manager
    vim
    git
    wget
    curl
    zip
    unzip
    tree
    fzf
    fd
    trash-cli
    neovim
    strace
    alacritty
    mpv
    feh
    tmux
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
    acpi
    # findutils
    hyfetch
    uwufetch

    ### Desktop #####################################################

    mako  # notification daemon
    libnotify  # notify-send
    wlsunset  # color temperature
    sway-contrib.grimshot  # screenshot
    bemenu  # dmenu replacement
    wbg  # minimal wallpaper daemon
    wl-clipboard-rs  # cli clipboard access
    # wmenu
    alsa-utils  # provides amixer, aplay
    brightnessctl
    playerctl
    wlr-which-key # which-key functionality
    swaylock
    swayidle
    lswt
    xwayland
    waylock
    fuzzel      # app launcher
    waybar      # taskbar
    hyprpaper    # wallpapers
    hyprpicker   # color-picker
    kooha
    hyprland-per-window-layout
    networkmanagerapplet
    pavucontrol
    xfce.thunar
    nicotine-plus

    ### Dev/Scripts #################################################

    gcc
    valgrind
    pkg-config
    # libxkbcommon
    clang-tools
    devenv
    ghc
    gnumake
    colordiff
    poppler-utils  # for pdftotext
    vorbis-tools  # for vorbiscomment
    jmtpfs
    cargo
    cargo-modules
    cargo-binstall
    rustc
    rustfmt
    rustPackages.clippy
    rust-analyzer
    lua-language-server
    jdt-language-server
    haskell-language-server
    jdk
    nixd
    typst
    # python3Full
    # inputs.rustowl-flake.packages.${system}.rustowl
    # espeak
    nix-output-monitor
    # vulnix
    nix-diff

    ### Applications ################################################

    firefox
    librewolf
    gimp
    keepassxc
    krita
    river-classic
    # river
    calibre
    ungoogled-chromium
    kdePackages.kdeconnect-kde
    libreoffice-fresh hunspell hunspellDicts.en-us-large
    obs-studio
    vesktop
    mtpaint
    anki
    signal-desktop
    milkytracker
    goattracker
    furnace
    # pkgs-stable.openmsx
    boops
    kdePackages.kdenlive
    ani-cli
    # temp fix for mixxx till 2.6
    (mixxx.overrideAttrs (oldAttrs: {
      version = "2.5-bleeding";
      src = fetchFromGitHub {
        owner = "mixxxdj";
        repo = "mixxx";
        rev = "16d57ca6f7496103d2a1376ceafcff823bc31fa0";
        hash = "sha256-qea93tb1uTXwJeJpPYbXemQpBZBPos1WXR/bKgXNjUc=";
      };
    }))
    wireshark

  ];

  fonts.packages = with pkgs; [
    # mono
    fira-code
    hack-font
    jetbrains-mono
    maple-mono.truetype
    pkgs-stable.iosevka
    aporetic
    nerd-fonts.iosevka

    # bitmap
    tamzen
    uw-ttyp0

    # variable
    vollkorn
    recursive
    xits-math
    liberation_ttf

    # japanese
    ipaexfont

    # latex
    libertinus

    # symbols
    font-awesome
    nerd-fonts.symbols-only

    # nerdfonts
    # (pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})

    # custom
    (iosevka.override {
      set = "Custom";
      privateBuildPlan = ''
        [buildPlans.IosevkaCustom]
        family = "Iosevka Custom"
        spacing = "normal"
        serifs = "sans"
        noCvSs = true
        exportGlyphNames = false

          [buildPlans.IosevkaCustom.ligations]
          inherits = "dlig"

        [buildPlans.IosevkaCustom.weights.Regular]
        shape = 400
        menu = 400
        css = 400

        [buildPlans.IosevkaCustom.weights.Bold]
        shape = 700
        menu = 700
        css = 700

        [buildPlans.IosevkaCustom.slopes.Upright]
        angle = 0
        shape = "upright"
        menu = "upright"
        css = "normal"

        [buildPlans.IosevkaCustom.slopes.Italic]
        angle = 9.4
        shape = "italic"
        menu = "italic"
        css = "italic"
      '';
    })
  ];
}
