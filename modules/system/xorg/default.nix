{ mkFeature, ... }:

# {
#   imports = [

#     (mkFeature "xorg" "Enable xorg" {
#       services.xserver.enable = true;
#       services.xserver.startx.enable = true;
#     })

#     (mkFeature "xmonad" "Enable xmonad" {
#       services.xserver.windowManager.xmonad.enable = true;
#     })
#   ];
# }
