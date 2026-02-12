{ inputs, mkFeature, ... }:

{
  imports = [
    inputs.stardew-modding.homeManagerModules.default

    (mkFeature "smapi" "Stardew Valley mod loader" {
      programs.stardew-modding = {
        enable = true;
        # Optional: customize paths
        # steamPath = "~/.local/share/Steam";
        # backupDir = "~/StardewBackups";
        # syncToCloud = true;
        # cloudPath = "~/OneDrive/StardewMods";
      };
    })
  ];

}
