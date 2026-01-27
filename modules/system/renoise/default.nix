{ pkgs, pkgs-stable, inputs, mkFeature, ... }:

let
  din-is-noise   = pkgs.callPackage ./din-is-noise { withJack = true; };
  renoise-custom = pkgs.callPackage ./renoise { inherit inputs; };
  lsp-plugins    = pkgs.callPackage ./lsp-plugins {};
  rave-gen-2     = pkgs.callPackage ./rave-generator-2 {};
  ildaeil        = pkgs.callPackage ./ildaeil {};
  vcv-working    = pkgs.callPackage ./vcv-rack {};
in {
  imports = [
    inputs.musnix.nixosModules.musnix # bring into scope

    (mkFeature "renoise" "Enable Renoise DAW and VSTs" {

      # # temp: firejail fix: allow unprivileged user to create namespaces
      # boot.kernel.sysctl."kernel.unprivileged_userns_clone" = "1";

      # # renoise firejail wrapper
      # programs.firejail.enable = true;
      # programs.firejail.wrappedBinaries.renoise = {
      #   executable = "${renoise-custom}/bin/renoise";
      #   profile = "/etc/firejail/renoise.profile";
      # };
      # environment.etc = {
      #   "firejail/renoise.profile".source = ./renoise.profile;
      # };

      # setup realtime realtime
      musnix = {
        enable = true;
        rtcqs.enable = true;
        das_watchdog.enable = true; # prevent realtime hangs?
      };

      environment.systemPackages = with pkgs; [
        ## Custom
        renoise-custom
        # din-is-noise
        # lsp-plugins
        # rave-gen-2 # gave up, just use yabridge, plsssssssssssssss
        # ildaeil # gave up, cant get working
        (let # wrapper includes package
          vcv-rack-wrapper = writeShellScriptBin "Rack" ''
            #!${runtimeShell}
            # This script does one thing: it unsets WAYLAND_DISPLAY
            # and then executes the *real* Rack binary, passing along all
            # command-line arguments ("$@").
            # Using 'exec' is a good practice as it replaces the wrapper
            # process with the actual application process.
            exec env -u WAYLAND_DISPLAY ${vcv-working}/bin/Rack "$@"
          '';
        in
          vcv-rack-wrapper
        )

        ## Synths
        bespokesynth
        pkgs-stable.surge-XT
        pkgs-stable.zynaddsubfx
        geonkick
        # pkgs-stable.vcv-rack
        # vcv-rack
        # pkgs-stable.glfw # vcv depend?
        glfw # vcv depend?
        cardinal # foss VCV-rack (only self-contained modules)
        dexed
        ams
        # bristol
        vital

        ## yabridge setup
        yabridge
        yabridgectl
        wineWowPackages.stable
        winetricks

        ## Daws
        reaper
        audacity
        bitwig-studio # proprietary!!!
        sunvox

        ## Tools
        mpg123 # mp3 playing support
        rubberband # timestretching
        qpwgraph # Jack connections interface
        carla # audio plugin host (maybe run Lv2 inside?!?!)

        ## VSTs
        fire               # multi-band distortion
        metersLv2    # volume analyzer (Lv2 format...)
        guitarix     # distortion pedals (jack only?)
        chow-kick     # classic drum generator
        # chow-phaser   # phaser
        stone-phaser  # better phaser
        dragonfly-reverb # reverbs
        delayarchitect # nice delay

        # calf         # set of plugins (no gui, broken, nah)
      ];
    })
  ];
}
