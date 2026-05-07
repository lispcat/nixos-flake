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
    })
  ];
}
