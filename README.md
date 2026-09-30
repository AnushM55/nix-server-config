# NixOS Hetzner base configuration

Minimal flake for installing NixOS on Hetzner. The config id is `hetzner-x86_64`.

## Install from a remote flake

```bash
sudo nixos-install --flake github:<username>/<repo>#hetzner-x86_64
```

Once installed, unmount the ISO and reboot.

## Before installing

1. Replace `username` in `configuration.nix` with your actual username.
2. Replace the placeholder entry in `openssh.authorizedKeys.keys` with your SSH public key.
3. Check `boot.loader.grub.device` matches your disk (`/dev/sda`).
4. Check the `fileSystems` / `swapDevices` labels match your partition scheme
   (`nixos`, `boot`, `swap`).

## Access

Ensure port 22 on the VM is opened via the Hetzner firewall, if one is configured.
