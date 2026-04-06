{ pkgs, mkFeature, user, ... }:

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

          settings.Resolve = {
            DNSOverTLS = "true";
            DNSSEC = "false";
            Domains = [ "~." ];
            FallbackDNS = dns-list;
          };

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

    (mkFeature "sshd" "Enable sshd server" {
      services.openssh = {
        enable = true;
        ports = [ 22 ];
        settings = {
          PasswordAuthentication = false;  # disable password login
          PermitRootLogin = "no";
          X11Forwarding = true;
          KbdInteractiveAuthentication = false;  # disables PAM challenge auth
        };
      };

      # Open firewall for SSH
      networking.firewall.allowedTCPPorts = [ 22 ];

      # Add your public key for a user
      users.users.${user}.openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6gBRMaUl6yaYPhK/haWqtxpw93Iylooq1DL+0nNmtFj7Mhhx+LF0X2BpHWzL2nh98zIvwHTPqG4g7r6NvofjCJkm8bCtXF8V/wj5aZ2RLANbI9Ugb+yOyv+eZ8yQf405hnf2p59fs8yYNK7mq/Io9cFh8QD7bjm+FFbfayVWsu84r1sXQxc+U/OSOqgGDVjT+mEFp/9nbf2T8nkTLCUm1RbKRm7Khp7UKcivC4OzGpSWtktZkk8TKvCuuoAgmfjVdN2fRE5WsWAId9jxW7jGsXhPhqmQdPS4tmqH/OyqcHWT0i4yXSwnn1+8j2OawTj75y4uLq2MSxyK3GUlP9kTH openpgp:0xDDCDF03F"
        # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4oNjjxB71fgm3NlU9rH6BJQlStA3YF0qvfDO2uFUXXl5SSLbZMGDr4OSjowvFeSby4Rm4xMjOPNSLTjHxncpkW4L+Io3GXzrRPVMWtcwRpRQaNbCOz5Ni7AqGTRii6VpCJfiZ/g/ptMhxPtVQX4K4R1J4QLCUs3MkhHJoccxABGIGAhvsa26ObzCLxeySP7i7aAdAC9xTKDXrSZebznLwX0QiK6zPY6pgvRz7E23wl0XV2J/3YzhtW3uysHwsaupdWfPpvndmOile30hRP2AUB12Prp+g2uqmTbU+OwQIdvRT3yQ+yVxZdgSx30X7fJyc/pYFS5iddy9RWe5dKbj7IC7TRxcp3uM87mWZEOScPMGc48v5R/Bkf1KM2DVqfNhJdep38m1GVEMk+SwOfsq98w/xsGhMdLqAdh+O1cerBmNN65EFNQ59/8BzEqu0RTE/kABDkRrq/aKyjB8iJHWmmdVGeYjhpGvdD8X67t98kC7cxwP/ikjDfz4UOn5Sh9E= openpgp:0x8DF11607"
      ];

      # bans IPs after repeated failed attempts
      services.fail2ban.enable = true;
    })

    # Note: after enabling, run `sudo tailscale up` to activate (persists).
    # Connect with `user@homelab-hostname`.
    # Ensure tailscale is also installed and running on client device.
    # Get homelab hostname with `tailscale status` on server.
    # Can also use IP instead of hostname.
    (mkFeature "tailscale" "Enable tailscale" {
      services.tailscale.enable = true;
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      # Optionally restrict SSH to tailscale interface only:
      # Upd: actually this isnt necessary and causes headaches
      # services.openssh.listenAddresses = [{ addr = "100.x.x.x"; port = 22; }];
    })
  ];
}
