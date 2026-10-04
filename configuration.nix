{ config, pkgs, ... }:
let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
in
{
  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  environment.systemPackages = [
    pkgs.vim
    pkgs.git
  ];

  nix.optimise.automatic = true;



  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "ext4";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];


  users.users = {
    root.hashedPassword = "!"; # Disable root login
    gopher = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3Q+saqzuXo8imMpm/I4enBjNBQkRb9MWD4dtsn6IIN laptop"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
    services.tailscale.enable = true;
    services.caddy = {
        enable = true;
        virtualHosts."vcs.anushm55.com".extraConfig = ''
          reverse_proxy 127.0.0.1:3000
        '';
    };

	services.forgejo = {
	    enable = true;
	    database.type = "postgres";
	    # Enable support for Git Large File Storage
	    lfs.enable = true;
	    settings = {
	      server = {
	        DOMAIN = "vcs.anushm55.com";
	        # You need to specify this to remove the port from URLs in the web UI.
	        ROOT_URL = "https://${srv.DOMAIN}/"; 
	        HTTP_PORT = 3000;
	      };
	      # You can temporarily allow registration to create an admin user.
	      service.DISABLE_REGISTRATION = true; 
	      # Add support for actions, based on act: https://github.com/nektos/act
	      actions = {
	        ENABLED = true;
	        DEFAULT_ACTIONS_URL = "github";
	      };
	      # Sending emails is completely optional
	      # You can send a test email from the web UI at:
	      # Profile Picture > Site Administration > Configuration >  Mailer Configuration 
	    };
	  };
	
	
	
	
	





    
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    # Always allow traffic from your Tailscale network
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled.serviceConfig.Environment = [ 
    "TS_DEBUG_FIREWALL_MODE=nftables" 
  ];

  # 3. Optimization: Prevent systemd from waiting for network online 
  # (Optional but recommended for faster boot with VPNs)
  systemd.network.wait-online.enable = false; 
  boot.initrd.systemd.network.wait-online.enable = false;

  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "24.11";
}
