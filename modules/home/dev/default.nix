{ pkgs, mkFeature, ... }:

{
  imports = [
    (mkFeature "git" "Setup git with name and email" {
      programs.git = {
        enable = true;
        settings = {
          user.name  = "lispcat";
          user.email = "187922791+lispcat@users.noreply.github.com";
          init.defaultBranch = "main";
        };
      };
    })
    (mkFeature "dev-env" "Enable direnv and lorri for dev envs" {
      programs.direnv.enable = true;
      services.lorri.enable = true;
    })
    (mkFeature "tmux" "Enable tmux support" {
      programs.tmux = {
        enable = true;
        prefix = "M-m";
        historyLimit = 10000;
        newSession = true;  # not needed?
        mouse = true;
        clock24 = true;
      };
    })
    (mkFeature "gpg" "Enable gpg and gpg-agent" {
      programs.gpg.enable = true;
      home.packages = with pkgs; [
        # pinentry-
      ];
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-qt;
        enableSshSupport = true;
        # dont forget to run WM with zsh -l -c 's%'
        enableZshIntegration = true;
        enableExtraSocket = true;
        defaultCacheTtl = 28800;
        defaultCacheTtlSsh = 28800;
        maxCacheTtl = 28800;
        maxCacheTtlSsh = 28800;
        extraConfig = ''
          allow-emacs-pinentry
        '';
        sshKeys = [
          # Provide the keygrip
          "E853C145BE1BA0A27CD219E4AF2DB12D14AA6968"
          "5D3BF86600C933F67035FF3CE16C170065584BE8"
        ];
      };
    })
  ];
}
