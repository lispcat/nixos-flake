{ lib, mkFeature, ... }:

{
  imports = [
    (mkFeature "zsh" "Enable zsh config for user" {
      programs.zsh = {
        enable = true;

        autosuggestion.enable = true;

        history = {
          save = 10000;
          size = 10000;
        };

        sessionVariables = {
          PATH = "$PATH:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/Scripts";

          # CC = "gcc";
          LC_COLLATE = "C";
          EDITOR = "emacsclient";
          VISUAL = "emacsclient";

          LSP_USE_PLISTS = "true"; # emacs lsp-booster

          ### --- WAYLAND --- ###

          # -- app-specific --
          NIXOS_OZONE_WL = "1"; # enable native wayland on chromium/electron
          ANKI_WAYLAND = "1"; # anki wayland
          MOZ_ENABLE_WAYLAND = "1"; # firefox wayland

          # -- Toolkit backends (with fallbacks) --
          QT_QPA_PLATFORM = "wayland;xcb"; # Qt backend
          GDK_BACKEND = "wayland,x11,*"; # GTK backend

          # -- WM fixes --
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"; # prevent title bars/borders

          # -- Input method --
          ## Fcitx input related
          XMODIFIERS = "@im=fcitx";
          QT_IM_MODULES = "wayland;fcitx;ibus";
          GLFW_IM_MODULE = "fcitx";
        };

        shellAliases = {
          em = "emacsclient -c -a ''";
          l = "ls -p --color=auto";
          ls = "ls -p --color=auto";
          la = "ls -a --color=auto";
          ll = "ls -lh --color=auto";
          lla = "ls -lha --color=auto";
          rm = "rm -i";
          ts = "trash";
          b = "cd ..";
          p = "cd -";

          iping = "ping gnu.org";
          recursive-find = "grep -rnw . -e";
        };

        initContent = lib.mkOrder 550 ''
          # autosuggestion text color
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#757575'

          # completion
          autoload -U compinit; compinit
          zstyle ':completion:*' menu select

          # emacs eat intergration
          [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
            source "$EAT_SHELL_INTEGRATION_DIR/zsh"
        '';
      };
    })
  ];
}
