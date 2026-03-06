{ pkgs, mkFeature, ... }:

{
  imports = [
    (mkFeature "mullvad" "Enable Mullvad VPN support" {
      services.mullvad-vpn = {
        enable = true;
        enableExcludeWrapper = true;
        package = pkgs.mullvad-vpn;
      };
    })

    (mkFeature "bluetooth" "Enable bluetooth support" {
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      hardware.bluetooth.settings = {
        Policy = {
          AutoEnable = true;
        };
      };
    })

    (let
      dns-list = [
        # "194.242.2.2#dns.mullvad.net"
        "194.242.2.3#adblock.dns.mullvad.net"
        # "194.242.2.4#base.dns.mullvad.net"
        # "194.242.2.5#extended.dns.mullvad.net"
        # "194.242.2.6#family.dns.mullvad.net"
        # "194.242.2.9#all.dns.mullvad.net"
        "94.140.15.15"
      ];
    in
      mkFeature "dns-over-https" "Enable DNS over HTTPS" {
        ### DNS over HTTPS and DNS over TLS

        networking.networkmanager.dns = "systemd-resolved";
        networking.nameservers = dns-list;
        networking.resolvconf.useLocalResolver = true;
        services.resolved = {
          enable = true;
          dnssec = "false";
          # dnssec = "true";
          dnsovertls = "true";
          domains = [ "~." ];
          fallbackDns = dns-list;
        };
      }
    )

    (mkFeature "vpn-proxy" "Enable per-app vpn proxy" {
      virtualisation.oci-containers = {
        backend = "docker";
        containers = {
          vpn = {
            image = "qmcgaw/gluetun";
            extraOptions = [
              "--cap-add=NET_ADMIN"
              "--dns=1.1.1.1"
            ];
            ports = [ "127.0.0.1:1080:1080" ];
            environmentFiles = [ "/etc/secrets/gluetun.env" ];
          };
          socks-proxy = {
            image = "tarampampam/3proxy";
            extraOptions = [ "--network=container:vpn" ];
            dependsOn = [ "vpn" ];
          };
        };
      };
    })
  ];
}
