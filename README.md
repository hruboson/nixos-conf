# NixOS configuration

This is my personal configuration for NixOS. I will most likely split this to multiple repositories or
branches for my server/workstation/other... I've also tried writing up a small tutorial for my first
installation of NixOS. See the [Manual](#Manual) section if this is your first time installing NixOS.

# Manual

## 1. Installation
Just recently I found `sudo nix run github:km-clay/nixos-wizard --extra-experimental-features nix-command --extra-experimental-features flakes` command that runs TUI (terminal user interface) installer, maybe give it a try or follow the manual installation.
This installations uses an EFI system partition for booting.

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


