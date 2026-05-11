{ pkgs, mkFeature, ... }:

# TODO: replace the spotify in the Nix store with this wrapped one!
{
  imports = [
    (mkFeature "firejail" "Creates some firejail wrappers" {

      programs.firejail.enable = true;

      ##

      environment.systemPackages = with pkgs; [
        spotify
      ];

      ### Spotify #######################################################

      programs.firejail.wrappedBinaries.spotify = {
        executable = "${pkgs.spotify}/bin/spotify";
        profile = "${pkgs.firejail}/etc/firejail/spotify.profile";
      };
      environment.etc = {
        "firejail/spotify.local".text = ''
          # allow links that open in browser to access librewolf profiles
          noblacklist ''${HOME}/.librewolf
          whitelist ''${HOME}/.librewolf/profiles.ini
        '';
      };

      ### Prismlauncher #################################################

      programs.firejail.wrappedBinaries.prismlauncher = {
        executable = "${pkgs.prismlauncher}/bin/prismlauncher";
        profile = "${pkgs.prismlauncher}/etc/firejail/prismlauncher.profile";
      };

      ### Wine #################################################

      environment.etc = {
        "firejail/wine-plugins.profile".text = ''
          blacklist ~/.ssh
          blacklist ~/.gnupg
          blacklist ~/.password-store
          blacklist ~/.mozilla
          blacklist ~/.librewolf
          blacklist ~/.config/chromium
          blacklist ~/.config/BraveSoftware
          blacklist ~/.zsh_history
          blacklist ~/.bash_history
          blacklist ~/NixOS
          blacklist ~/Notes
          blacklist ~/Pictures
          blacklist ~/Private
          blacklist ~/Projects
          blacklist ~/School
          blacklist ~/Src
          blacklist ~/Videos
          blacklist ~/opt
          blacklist ~/slsk-vpn
          blacklist ~/wireguard
          blacklist ~/tmp

          blacklist /boot
          blacklist /sys/firmware
          blacklist /sys/kernel/debug

          caps.drop all
          # nosuid
          nonewprivs
          noroot
          nodvd
          notv
          novideo

          private-tmp
        '';
      };
      programs.firejail.wrappedBinaries.wine = {
        executable = "${pkgs.wineWow64Packages.stable}/bin/wine";
        profile = "/etc/firejail/wine-plugins.profile";
      };

    })
  ];
}
