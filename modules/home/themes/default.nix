{ pkgs, mkFeature, ... }:

{
  imports = [
    (mkFeature "app-theme-def" "Enables qt and gtk (def variant)" {

      ## QT ## ---------------------------------------------

      # https://github.com/raexera/yuki/blob/main/home/raexera/config/qt.nix
      qt = {
        enable = true;
        platformTheme = "qtct";
        style.name = "kvantum";
      };

      # qtTheme = {
      #   name = "Catppuccin-Mocha-Mauve";
      #   package = pkgs.catppuccin-kvantum.override {
      #     variant = "Mocha";
      #     accent = "Mauve";
      #   };
      # };


      ## GTK ## --------------------------------------------

      gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };

        theme = {
          package = pkgs.colloid-gtk-theme;
          name = "Colloid-Dark";

          # name = "Catppuccin-Mocha-Compact-Mauve-Dark";
          # package = pkgs.catppuccin-gtk.override {
          #   accents = [ "mauve" ];
          #   size = "compact";
          #   variant = "mocha";
          #   # tweaks = [ "rimless" ];
          # };
          
        };

        gtk2.extraConfig = ''
          gtk-im-module="fcitx"
        '';

        gtk3 = {
          extraConfig.gtk-application-prefer-dark-theme = true;
          extraConfig.gtk-im-module = "fcitx";    # fcitx

          ## GTK headerbar ## --------------------
          extraConfig.gtk-dialogs-use-header = false;
          extraCss = ''
            /*** River GTK headerbar hack: ***/

            /* No (default) title bar on wayland */
            headerbar.default-decoration {
              /* You may need to tweak these values depending on your GTK theme */
              margin-bottom: 50px;
              margin-top: -100px;
            }

            /* rm -rf window shadows */
            window.csd,             /* gtk4? */
            window.csd decoration { /* gtk3 */
              box-shadow: none;
            }
          '';
        };

        gtk4 = {
          extraConfig.gtk-application-prefer-dark-theme = true;
          extraConfig.gtk-im-module = "fcitx";    # fcitx

          ## GTK headerbar ## --------------------
          extraConfig.gtk-dialogs-use-header = false;
          extraCss = ''
            /* River GTK headerbar hack: */
  
            /* No (default) title bar on wayland */
            headerbar.default-decoration {
              /* You may need to tweak these values depending on your GTK theme */
              margin-bottom: 50px;
              margin-top: -100px;
            }
  
            /* rm -rf window shadows */
            window.csd,             /* gtk4? */
            window.csd decoration { /* gtk3 */
              box-shadow: none;
            }
          '';
        };
      };
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    })
  ];
}

  ## Old

  # gtk = {
  #   enable = true;
  #   iconTheme = {
  #     name = "Kanagawa";
  #     package = pkgs.kanagawa-icon-theme;
  #   };
  #   theme = {
  #     name = "vimix-dark-compact-amethyst";
  #     package = pkgs.vimix-gtk-themes.override {
  #       colorVariants = [ "dark" ];
  #       sizeVariants =  [ "compact" ];
  #       themeVariants = [ "amethyst" ];
  #       # tweaks = [ "flat" ];
  #     };
  #   };
  # };

  # river gtk bar fix

  # gtk.gtk3.extraCss = ''
  #   /* No (default) title bar on wayland */
  #   headerbar.default-decoration {
  #     /* You may need to tweak these values depending on your GTK theme */
  #     margin-bottom: 50px;
  #     margin-top: -100px;
  #   }

  #   /* rm -rf window shadows */
  #   window.csd,             /* gtk4? */
  #   window.csd decoration { /* gtk3 */
  #     box-shadow: none;
  #   }
  # '';
  # gtk.gtk4.extraCss = ''
  #   /* No (default) title bar on wayland */
  #   headerbar.default-decoration {
  #     /* You may need to tweak these values depending on your GTK theme */
  #     margin-bottom: 50px;
  #     margin-top: -100px;
  #   }

  #   /* rm -rf window shadows */
  #   window.csd,             /* gtk4? */
  #   window.csd decoration { /* gtk3 */
  #     box-shadow: none;
  #   }
  # '';


  ### Other themes

  # comfy but hard to read
  # gtk.theme = {
  #   name = "catppuccin-macchiato-mauve-compact";
  #   package = pkgs.catppuccin-gtk.override {
  #     variant = "macchiato";
  #     accents = [ "mauve" ];
  #     size = "compact";
  #   };
  # };

  # comfy, somewhat good to read, but firefox highlight is weird
  # gtk.theme = {
  #   name = "Matcha-dark-azul";
  #   package = pkgs.matcha-gtk-theme;
  # };

  # kinda nice
  # gtk.theme = {
  #   name = "Materia-dark-compact";
  #   package = pkgs.materia-theme;
  # };

  # mid
  # gtk.theme = {
  #   name = "Flat-Remix-GTK-Teal-Dark";
  #   package = pkgs.flat-remix-gtk;
  # };

  # gtk.theme = {
  #   name = "Adwaita-dark";
  #   package = pkgs.gnome-themes-extra;
  # };

  # gtk.theme = {
  #   name = "Nordic";
  #   package = pkgs.nordic-theme;
  # };

  # gtk.theme = {
  #   name = "Dracula";
  #   package = pkgs.dracula-theme;
  # };

  # unmaintained and blue but very very easy to read
  # gtk.theme = {
  #   name = "Vertex-Dark";
  #   package = pkgs.theme-vertex;
  # };

  # gtk.theme = {
  #   name = "Tokyonight-Dark-Storm";
  #   package = pkgs.tokyonight-gtk-theme.override {
  #     tweakVariants = [ "storm" ];
  #   };
  # };

  # gtk.theme = {
  #   name = "Gruvbox-Purple-Dark";
  #   package = pkgs.gruvbox-gtk-theme.override {
  #     themeVariants = [ "purple" ];
  #     colorVariants = [ "dark" ];
  #   };
  # };

  # gtk.theme = {
  #   name = "Nightfox-Dark";
  #   package = pkgs.nightfox-gtk-theme;
  # };

  # gtk.theme = {
  #   name = "Arc-dark";
  #   package = pkgs.arc-theme;
  # };
