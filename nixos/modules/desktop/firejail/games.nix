{ pkgs, lib, ... }:

{
  ## Steam

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
    localNetworkGameTransfers.openFirewall = false;
  };
  
  nixpkgs.allowUnfreePackages = [
    "steam"
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
  ];
  
  programs.firejail.wrappedBinaries.steam = {
    executable = "${pkgs.steam}/bin/steam";
    profile = "${pkgs.firejail}/etc/firejail/steam.profile";
  };
  programs.firejail.wrappedBinaries.steam-run = {
    executable = "${pkgs.steam}/bin/steam-run";
    profile = "${pkgs.firejail}/etc/firejail/steam.profile";
  };
  
  environment.etc = {
    "firejail/steam.local".text = ''
      # Allow VR and camera-based motion tracking
      ignore novideo
      # seccomp sometimes causes issues...
      ignore seccomp
      # private-etc breaks a small handful of games...
      ignore private-etc
      
      # whitelist dirs
      whitelist ''${HOME}/Games/
      whitelist ''${HOME}/Desktop/
    '';
  };

  ## Prismlauncher

  programs.firejail.wrappedBinaries.prismlauncher = {
    executable = "${pkgs.prismlauncher}/bin/prismlauncher";
    profile = "${pkgs.firejail}/etc/firejail/prismlauncher.profile";
  };

}
