{ mkFeature, ... }:

{
  imports = [
    (mkFeature "laptop-power" "Enable powersaving features" {
      # thermald (prevent overheating)
      services.thermald.enable = true;

      # tlp (power saving)
      services.tlp = {
        enable = true;
        settings = {

          ### Optimizing guide:
          ### https://linrunner.de/tlp/support/optimizing.html

          ### GENERIC:

          # battery cap
          START_CHARGE_THRESH_BAT0 = 50;
          STOP_CHARGE_THRESH_BAT0 = 90;
          # START_CHARGE_THRESH_BAT0 = 65;
          # STOP_CHARGE_THRESH_BAT0  = 70;

          ### AC performance #########################################

          CPU_SCALING_GOVERNOR_ON_AC = "balance_performance";   # cpu
          CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance"; # cpu hint
          PLATFORM_PROFILE_ON_AC = "balanced";          # profile
          CPU_MIN_PERF_ON_AC = 0;                       # perf cap
          CPU_MAX_PERF_ON_AC = 90;
          CPU_BOOST_ON_AC = 1;                          # turbo

          ### Battery performance ####################################

          CPU_SCALING_GOVERNOR_ON_BAT = "balance_power";   # cpu
          CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power"; # cpu hint
          PLATFORM_PROFILE_ON_BAT = "balanced";          # profile
          CPU_MIN_PERF_ON_BAT = 0;                       # perf cap
          CPU_MAX_PERF_ON_BAT = 65;
          CPU_BOOST_ON_BAT = 0;                          # turbo

          ### Battery MAXIMUM CHARGE #################################

          ## temporarily disabled for battery drain

          # CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; # cpu
          # CPU_ENERGY_PERF_POLICY_ON_BAT = "power";   # energy
          # PLATFORM_PROFILE_ON_BAT = "low-power";     # platform
          # RUNTIME_PM_ON_BAT = "auto";                # off idle devices ("on" causes boot hanging)
          # CPU_MIN_PERF_ON_BAT = 0;                   # perf cap
          # CPU_MAX_PERF_ON_BAT = 5;
          # CPU_BOOST_ON_BAT = 0;                      # turbo
          # CPU_BOOST_ON_SAV = 0;
          # CPU_HWP_DYN_BOOST_ON_BAT = 0;
          # AMDGPU_ABM_LEVEL_ON_BAT = 3;               # backlight adj
          # PCIE_ASPM_ON_BAT = "powersupersave";       # pcie devices
          # USB_AUTOSUSPEND = 1;                       # usb suspend

          # CPU_HWP_DYN_BOOST_ON_SAV = 0; (maybe causing problem?)

          ### Battery good ###########################################

          # CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; # cpu
          # CPU_ENERGY_PERF_POLICY_ON_BAT = "power";   # energy
          # PLATFORM_PROFILE_ON_BAT = "balanced";      # platform
          # RUNTIME_PM_ON_BAT = "auto";                # off idle devices
          # CPU_MIN_PERF_ON_BAT = 0;                   # perf cap
          # CPU_MAX_PERF_ON_BAT = 20;
          # CPU_BOOST_ON_BAT = 0;                      # turbo
          # CPU_BOOST_ON_SAV = 0;
          # CPU_HWP_DYN_BOOST_ON_BAT = 0;
          # CPU_HWP_DYN_BOOST_ON_SAV = 0;
        };
      };

      services.upower = {
        enable = true;
        criticalPowerAction = "HybridSleep";
      };
    })
  ];
}

