{ inputs, ... }:

{
  imports = [
    inputs.stardew-modding.homeManagerModules.default
  ];

  programs.stardew-modding = {
    enable = true;
    # Optional: customize paths
    # steamPath = "~/.local/share/Steam";
    # backupDir = "~/StardewBackups";
    # syncToCloud = true;
    # cloudPath = "~/OneDrive/StardewMods";
  };
}
