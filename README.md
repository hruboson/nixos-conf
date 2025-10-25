# NixOS configuration

This is my personal configuration for NixOS. I will most likely split this to multiple repositories or
branches for my server/workstation/other... I've also tried writing up a small tutorial for my first
installation of NixOS. See the [Manual](#Manual) section if this is your first time installing NixOS.

# Manual

## 1. Installation
Just recently I found `sudo nix run github:km-clay/nixos-wizard --extra-experimental-features nix-command --extra-experimental-features flakes` command that runs TUI (terminal user interface) installer, maybe give it a try or follow the manual installation.
You will generally want to follow the [installation for x86-64 system](#11-manual-installation-on-x86-64-system) if you have something like desktop PC or laptop. If you have more specialized hardware, such as Raspberry Pi, your installation might look a bit different. I have so far only installed NixOS on Raspberry Pi 3B. To install NixOS on Raspberry Pi (3B) follow the [Raspberry Pi](#12-raspberry-pi-3b) manual.

### 1.1 Manual installation on x86-64 system
This installations uses an EFI system partition for booting. Bear that in mind when trying this method in a virtualization tool such as [Virtualbox](https://www.virtualbox.org/).

Manual installation:

- (optional) `sudo loadkeys cz-qwertz` - change keyboard locale
- `sudo -s`
- `lsblk` ... check drives
- create partition
    - `(sudo) fdisk /dev/sda`
    - `g`, `n` - UEFI boot partition, `<enter><enter>+500M` (500MB UEFI), `t` change partition type, `1` - EFI system, `n` - Swap partition, `<enter><enter>+4096M` (4GB swap), `t` change partition type, `2` - choose partition number (swap is 2, uefi 1), `19` - Linux swap partition number (see `L` for all), `n` - System partition, `<enter><enter><enter>` (Allocates rest),
    - `w` - write changes to disk
- `mkfs.fat /dev/sda1` - make FAT partition
- `mkswap /dev/sda2` - make swap partition
- `swapon /dev/sda2` - enable the swap partition
- `mkfs.ext4 /dev/sda3` - make ext4 partition on Linux filesystem
- `mount /dev/sda3 /mnt`
- `mkdir /mnt/boot` - create boot folder
- `mount /dev/sda1 /mnt/boot` - mount uefi partition to boot folder
- `nixos-generate-config --root /mnt/` - generate default config file
- (optional) if you have configuration ready (on github for example):
    - `cp -a /mnt/etc/nixos /root/nixos-config-backup` - backup the generated config
    - `rm -rf /mnt/etc/nixos/` - remove generated config
    - `git clone https://github.com/<username>/<nixos-conf.git> /mnt/etc/nixos`
    - **IMPORTANT** copy the `hardware-configuration.nix` back: 
        1. without flakes: `cp /root/nixos-config-backup/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix`
        2. with flakes (adjust to your config): `cp /root/nixos-config-backup/hardware-configuration.nix /mnt/etc/nixos/hardware/<flake-name>-hardware.nix`
- `nano /mnt/etc/nixos/configuration.nix` - edit config
- install and show all logs:
    1. without flakes: `nixos-install -v`
    2. without flakes: `nixos-install -v --flake /mnt/etc/nixos#<flake-name>`
- after successful installation it will ask for new password, this password will be for the root account
- `reboot` - after this it should boot to installed os

### 1.2 Raspberry Pi 3B

For the RPI installation I found [this guide](https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi.html) by [nix.dev](https://nix.dev/) to be the most useful.

I was setting up my SD card on a Windows machine using Etcher to flash it.

- download NixOS live image from [Hydra](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux)
    - this is different from installer - the system will already be installed on the sd card after flashing
    - just look for the latest (newest) build
    - at the time of writing this guide I used [nixos-image-sd-card-25.11pre882227.01f116e4df6a-aarch64-linux.img.zst](https://hydra.nixos.org/build/310514045)
- use [7-zip](https://www.7-zip.org/) or other extracting utility to extract the downloaded archive (`nixos-image-sd-card-*.img.zst`)
- use [Etcher](https://etcher.balena.io/) or other flashing utility to flash the `nixos-image-sd-card-*.img` onto the SD card
    - do not use the compressed file as that will not work
- now you can insert the SD card into the Raspberry Pi (turn it off before inserting)
- after inserting the SD card power on the Raspberry Pi, a basic NixOS command line (tty) should show up
    - what you see now is the live system - you will not have to install anything
    - from here on you can go your own way if you want and bring your own configuration, be careful tho because Raspberry Pi needs some specific settings turned on
- the basic configuration should look something like (for Raspberry Pi 3B):

```nix
# as of 24.10.2025 you can download this using (in elevated mode): curl -L https://tinyurl.com/tutorial-nixos-install-rpi4 > /etc/nixos/configuration.nix
{ config, pkgs, lib, ... }:

let
    user = "guest";
    password = "guest";
    SSID = "mywifi";
    SSIDpassword = "mypassword";
    interface = "wlan0";
    hostname = "myhostname";
in {

    boot = {
        kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
        initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
        loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
        };
    };

    fileSystems = {
        "/" = {
            device = "/dev/disk/by-label/NIXOS_SD";
            fsType = "ext4";
            options = [ "noatime" ];
        };
    };

    networking = {
        hostName = hostname;
        wireless = {
            enable = true;
            networks."${SSID}".psk = SSIDpassword;
            interfaces = [ interface ];
        };
    };

    environment.systemPackages = with pkgs; [ vim ];

    services.openssh.enable = true;

    users = {
        mutableUsers = false;
        users."${user}" = {
            isNormalUser = true;
            password = password;
            extraGroups = [ "wheel" ];
        };
    };

    hardware.enableRedistributableFirmware = true;
    system.stateVersion = "25.11";
}
```
- replace the `user`, `password`, `SSID` (wifi name), `SSIDpassword` (wifi password), `hostname` to your desired values
- create a swap file (otherwise rebuild takes waaaaaaaaaaaay too long):
    - `sudo fallocate -l 4G /swap` - allocates 4GB for the swap file
    - `sudo chmod 600 /swap`
    - `sudo mkswap /swap`
    - `sudo swapon /swap`
- to enable and set WiFi before the first rebuild you can run `nmtui`
- rebuild and reboot the system:
    - `nixos-rebuild boot` - should take about 10-20 minutes depending on the speed of your internet connection
    - `reboot` - reboots the system

## 2. First login
- when first logging in the nixos login will be `root` with password you set during the `nixos-install`
- update channels (package repositories): `nix-channel --update`
- edit configuration in `/etc/nixos/configuration.nix`, use `nano /etc/nixos/configuration.nix` to edit that file
- uncomment lines starting with `networking.` and set `hostName`
- uncomment `services.openssh.enable = true;` - enables ssh
- set timezoone
- adding user by uncommenting the `users` section
- install packages by writing them in the `environment.systemPackages = with pkgs; [ ...`
- then **rebuild** nix using the `nixos-rebuild switch` (will probably take a while), it will take the configuration file and apply the changes we made in it
- apply password to the new user: `passwd username`

## 3.1 Setting up git and github
If you are comfortable using the GitHub CLI tool (`gh`), you can add it to your configuration. The package is `pkgs.gh`.

Or the old fashioned way using SSH keys (which is still quite easy on Linux):
- enable ssh agent and git in configuration:
    - `programs.ssh.startAgent = true;`
    - add `git` to system packages
    - you might have to reboot after this change
- generate ssh keys:
    - `ssh-keygen -t ed25519 -C "email@example.com"`
    - `ssh-add ~/.ssh/id_ed25519`
    - print the public key and upload it to github: `cat ~/.ssh/id_ed25519.pub`, on github go to Settings > SSH and GPG keys > New SSH ke
- creating new nixos configuration repository
    - `mkdir -p ~/nixos-conf` - create new directory in home directory to edit the config... this will be later used to rebuild the system
    -  `sudo cp -r /etc/nixos/* ~/nixos-conf/` - copy existing configuration
    - `sudo chown -R $USER ~/nixos-conf` - set ownership of the dir to current user
    - `echo "hardware-configuration.nix" >> ~/nixos-conf/.gitignore` - ignore `hardware-configuraton.nix` file in the git repository
    - `cd ~/nixos-conf`, `git init`, `git add .`, `git commit -m "Initial configuration"`, `git branch -M main`, `git remote add origin git@github.com:<username>/<nixos-conf.git>`, `git push -u origin main`
    - rebuild from the newly created directory: `sudo nixos-rebuild switch -I nixos-config=~/nixos-conf`
- editing already cloned repository (if you cloned config during installation)
    - `cp -r /etc/nixos ~/`
    - after changes rebuild with `sudo nixos-rebuild -I nixos-config=/home/<username>/nixos/configuration.nix`
- if you get prompt for username and password when pushing to git then try changing remote: `git remote set-url origin git@github.com:<username>/<repository.git>`

## 3.2 Flakes

## 3.3 Home-manager

#### 3.3.1 Plasma-manager

## 4. Desktop environment
