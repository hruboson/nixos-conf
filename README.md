# NixOS configuration

This is my personal configuration for NixOS. I will most likely split this to multiple repositories or
branches for my server/workstation/other... I've also tried writing up a small tutorial for my first
installation of NixOS. See the [Manual](#Manual) section if this is your first time installing NixOS.

# Using this configuration

If you want to use this configuration you first have to do few steps (currently only applies for #server and #raspberrypi flakes, #workstation should be fine without secrets):

1. clone the repository (duh)
2. create a folder `secrets/` (wherever you want, I recommend inside of this repository)
3. create `flake.nix` file in the `secrets/` folder with the folowing content:

```
{
	description = "Local secrets (not tracked)";

	outputs = { self, ... }:
	{
		wifiSSID = "WIFI_NAME";
		wifiPasswd = "WIFI_PASSWD";

        nextcloudAdminPassword = "NEXTCLOUD_ADMIN_PASSWORD";

        apiNasaKey = "NASA_API_KEY";
	};
}
```

4. `git init && git add . && git commit -m "Secrets"` inside of the `secrets/` folder
5. in `flake.nix` (of this repository) change the `url` of `secrets` in inputs to your created `secrets/` folder

```
secrets = {
	url = "path:/path/to/secrets"; #! It has to be an absolute path
};
```

# Manual

**Table of contents**
1. [Installation](#installation)
    1. [Graphical installer](#graphical-installer)
    1. [Minimal installer](#minimal-installer)
    1. [Raspberry pi 3B](#installation-raspberry)
    1. [QEMU on Windows host](#qemu-windows)
    1. [QEMU on Linux host](#qemu-linux)
1. [First login](#first-login)
1. [Git](#git)
1. [Flakes](#flakes)
1. [Home-manager](#home-manager)
    1. [Plasma manager](#plasma-manager)
1. [Desktop environment](#desktop-environment)
    1. [KDE](#desktop-environment-kde)
    1. [Sway](#desktop-environment-sway)
    1. [Hyprland](#desktop-environment-hyprland)
1. [NixOS optimizations](#nixos-optimizations)

## 1. Installation <a name="installation"></a>
Just recently I found `sudo nix run github:km-clay/nixos-wizard --extra-experimental-features nix-command --extra-experimental-features flakes` command that runs TUI (terminal user interface) installer, maybe give it a try or follow the manual installation.
You will generally want to follow the [installation for x86-64 system](#11-manual-installation-on-x86-64-system) if you have something like desktop PC or laptop. If you have more specialized hardware, such as Raspberry Pi, your installation might look a bit different. I have so far only installed NixOS on Raspberry Pi 3B. To install NixOS on Raspberry Pi (3B) follow the [Raspberry Pi](#12-raspberry-pi-3b) manual.

When installing NixOS in an virtual environment (such as in Virtualbox or VMware) be careful of the settings. I tried installing and running this config in both Virtualbox and VMware, both were quite a pain in the ass when working on Windows. Running this configuration in Virtualbox on Linux (Fedora 42) was easy and painless (damn you Windows!).

Be sure to enable EFI when creating the machine (this configuration probably won't work without EFI enabled). On Virtualbox I experienced brutal graphical lags when running KDE Plasma 6. I fixed this by switching to older graphics controller (VBoxSVGA or VBoxVGA). The newer graphics controller (VMSVGA) did not work, I was getting tons of visual glitches and the interface was so laggy I could not get anything done.

VMware seemed to run much smoother, altough at the time of writing this I have not figured out how to enable EFI in the settings.

If you plan on running any **Wayland** compositor such as **Sway** or **Hyprland** and want to run **NixOS in virtual machine on Windows**, **I strongly recommend** using [QEMU](https://www.qemu.org/) - see section [installing NixOS on QEMU virtual machine](#13-Installing-NixOS-on-virtual-machine-on-Windows-host-using-QEMU). I have not been able to run any Wayland compositor through Virtualbox or VMware on Windows. This tutorial might be a bit advanced than just using Virtualbox or VMware, but you should be able to customize the virtual machine more and mainly, as previously stated, be able to run **Wayland**.

### 1.1 Manual installation on x86-64 system <a name="installation"></a>

#### Using NixOS graphical installer <a name="graphical-installer"></a>

Installing NixOS using the graphical intaller is quite straightforward. I found it to be no harder than installing Fedora or Ubuntu.

Boot up your NixOS graphical installer and just follow the installer. You will be prompted to choose your Location, Keyboard layout, set up your user and root account, choose your desktop environment (choose whichever you like the most, if you want Windows-like choose KDE Plasma, if you want Mac-like choose Gnome), allow unfree software... 

Set up partitions - here you will have to select on which drive the system will install and also whether to erase the whole disk or manually partition. If you have a laptop or PC where there will only be one system (NixOS) you can select *Erase disk*. Also select a swap partition to be created, otherwise there is a good chance you might run out of RAM during the installation. If you want to utilize hybernation also select that. Oterwise every other settings should stay default. Click your way through the next buttons and start the installation by clicking the *Install* button. This process can take a while (about 30mins or more) depending on your hardware and your internet speed.

If it gets stuck at **46%** DO NOT PANICK. This is normal and it will take a while (could be up to an hour depending on your internet speed). At this point the NixOS installer is downloading all the necessary packages. You can see what it is downloading by clicking the *Toggle logs* button.

Once the system is installed you can reboot and remove the usb drive/cd/where you have nixos installation on. Then create a new config or bring already existing. Follow the [first login](#2-First-login) section for basic NixOS configuration and rebuild.

#### Using NixOS minimal iso <a name="minimal-installer"></a>

Boot up your NixOS minimal iso and run the following commands. Pay attention to some of the arguments to different commands as they may vary on your system.

- (optional) `sudo loadkeys cz-qwertz` - change keyboard locale
- `sudo -s`
- `lsblk` ... check drives
- create partition
    - `fdisk /dev/sda` (instead of `sda` your drive might have a different name, such as `sdb` or `sdc`)
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

### 1.2 Raspberry Pi 3B <a name="installation-raspberry"></a>

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

### 1.3 Installing NixOS on virtual machine on Windows host using QEMU <a name="qemu-windows"></a>

If you plan on running any Wayland compositor (such as *Sway* or *Hyprland*) through virtual machine on Windows, this is probably the best way to do it. I could not figure out how to run any Wayland compositor through Virtualbox or VMware.

Although setting up a QEMU virtual machine is much more difficult than just running Virtualbox or VMware, I found it to be much smoother experience once you have it set up. It also allows you to run Wayland compositors.

Install QEMU using the [Windows installer (20250819)](https://qemu.weilnetz.de/w64/qemu-w64-setup-20250819.exe) (or choose a newer version [here](https://qemu.weilnetz.de/w64/)). By default the QEMU binaries (.exe files) might not be in PATH. To add them, go to the directory where you installed QEMU, copy the path and add it to environment variables: in Windows search bar search for *environment variables*, click on *edit the system environment variables*, click on *Environment variables...*, double click the item Path under User (or System) variables, click *New* and paste the QEMU directory.

Also download the `OVMF/OVMF_CODE.fd` to be able to run UEFI instead of BIOS. At the time of writing this guide (14.11.2025) you can download it [here](https://github.com/kholia/OSX-KVM/raw/refs/heads/master/OVMF_CODE.fd).

The last piece of software you might need is a [TAP-windows 9.21.x](https://swupdate.openvpn.org/community/releases/tap-windows-9.21.2.exe). This program allows you to create a bridged connection for your virtual machine. This guide uses that and I recommend it, mostly just to be able to connect through ssh to your virtual machine. Setting it up in Windows is quite easy:

1. Install [TAP-windows 9.21.x](https://swupdate.openvpn.org/community/releases/tap-windows-9.21.2.exe) or newer version if installation fails
2. On Windows: go to Contzrol Panel -> Network and Sharing Center -> Change adapter settings
3. Select both Ethernet and your new TAP adapter (something like Ethernet 2 or Ethernet 3) - remember this one as you will need it later when running the QEMU virtual machine
4. Right click -> Bridge Connections
5. new bridge should be created

Now you are ready to actually set up the virtual machine.

First start by creating your disk image. To create a qcow2 image using QEMU, you can use the command: 

```
qemu-img.exe create -f qcow2 your_image_name.img size
```

Replace `your_image_name.img` with your desired file name and `size` with the size you want, such as 64G for 64 gigabytes. I recommend this size as its not too big but also not too small. In my experience a NixOS can get quite big if you don't optimise or clear your generations properly. 

I recommend installing the system using a graphical installer iso. Start the virtual machine with:

```
qemu-system-x86_64.exe ^
    -m 4096 -cpu max -smp 4 ^
    -device virtio-vga -display sdl ^
    -device virtio-keyboard-pci -device virtio-mouse-pci ^
    -nic user,model=virtio-net-pci ^
    -drive file="C:\Path\to\vm\nixos.qcow2",if=virtio,format=qcow2 ^
    -cdrom "C:\Path\to\iso\nixos.iso" ^
    -boot d ^
    -bios "C:\Path\to\qemu\OVMF_CODE.fd"
```

Change the `drive file="..."`,`-cdrom "..."` and `-bios "..."` arguments to paths to your files on your system.

Now you are in a graphical installer and the rest should be quite straightforward. Follow the [graphical installation manual](#Using_NixOS_graphical_installer). Once you are done you can shut down the virtual machine (either manually through the guest system or just close the QEMU window). At this point NixOS should be installed on your virtual drive (`your_drive.qcow2`).

When running installed system you don't have to specify the `-cdrom` path, so your qemu command should look something like:

```
qemu-system-x86_64.exe ^
    -m 4096 -cpu max -smp 4 ^
    -device virtio-vga -display sdl ^
    -device virtio-keyboard-pci -device virtio-mouse-pci ^
    -nic user,model=virtio-net-pci ^
    -drive file="C:\Path\to\vm\nixos.qcow2",if=virtio,format=qcow2 ^
    -bios "C:\Path\to\qemu\OVMF_CODE.fd"
```
Again change the `drive file="..."` and `-bios "..."` arguments. This should boot up virtual machine with NixOS installed.

I have also compiled a list of commands that might come in handy depending on what you are trying to achieve:

1. running QEMU with a bridged TAP adapter:

```
qemu-system-x86_64.exe ^
    -m 4096 -cpu max -smp 4 ^
    -device virtio-vga -display sdl ^
    -device virtio-keyboard-pci -device virtio-mouse-pci ^
    -netdev tap,id=mynet0,ifname="Ethernet 3",script=no,downscript=no ^
    -device virtio-net-pci,netdev=mynet0 ^
    -drive file="C:\Path\to\vm\nixos.qcow2",if=virtio,format=qcow2 ^
    -bios "C:\Path\to\qemu\OVMF_CODE.fd"
```
Change the `ifname` in `-netdev` argument to the name of your newly created adapter (the one you created at the beginning of this installation).

2. running Sway, Hyprland or any Wayland compositor

```
qemu-system-x86_64.exe ^
    -m 4096 -cpu max -smp 4 ^
    -device virtio-vga-gl ^
    -display sdl,gl=on ^
    -device virtio-keyboard-pci -device virtio-mouse-pci ^
    -netdev tap,id=mynet0,ifname="Ethernet 3",script=no,downscript=no ^
    -device virtio-net-pci,netdev=mynet0 ^
    -drive file="C:\Path\to\vm\nixos.qcow2",if=virtio,format=qcow2 ^
    -bios "C:\Path\to\qemu\OVMF_CODE.fd"
```
This runs much smoother by using the `virtio-vga-gl` and `-display sdl,gl=on`, but takes a bit longer to load. If all you see is black screen try resizing the QEMU window few times.
Change the `ifname` in `-netdev` argument to the name of your network adapter.

3. my cursor is upside down

To fix the goofy bug when your cursor is upside down but everything else looks perfect, you can try running:

```
qemu-system-x86_64.exe ^
    -m 4096 -cpu max -smp 4 ^
    -vga qxl ^
    -device virtio-keyboard-pci -device virtio-mouse-pci ^
    -netdev tap,id=mynet0,ifname="Ethernet 3",script=no,downscript=no ^
    -device virtio-net-pci,netdev=mynet0 ^
    -drive file="C:\Path\to\vm\nixos.qcow2",if=virtio,format=qcow2 ^
    -bios "C:\Path\to\qemu\OVMF_CODE.fd"
```

AND before running `sway` be sure to run `export WLR_NO_HARDWARE_CURSORS=1` (or set the environment variable somewhere).

### 1.4 Installing NixOS on virtual machine on Linux host using QEMU <a name="qemu-linux"></a>

This section covers how to install and run QEMU on Fedora. On Linux I did not bother with bridge and just used NAT. If you are using QEMU with a network bridge I'd appreciate if you opened a pull request and shared the steps you did to make it work :-).

I'm using the Fedora 42 distro. If you are on Ubuntu or Arch your installation will most likely be different. See [QEMU installation](https://www.qemu.org/download/#linux) manual for your specific distribution.

First check if virtualization is enabled in BIOS:
```
egrep -c '(vmx|svm)' /proc/cpuinfo
```
If the output of this command is **0** virtualization is disabled in BIOS.

Fedora ships with everything required to run QEMU/KVM efficiently. All you need to do is install the virutalization group:

```
sudo dnf install @virtualization
```

and some additional tools (might not be needed depending on your distro):

```
sudo dnf install qemu-kvm libvirt virt-install bridge-utils
```

After that you should be ready to run QEMU. Check that `which qemu` returns a valid path. If it does you are all set.

From now on the commands will be basically the same as in the Windows tutorial section. Create a virtual drive:
```
qemu-img create -f qcow2 your_image_name.qcow2 size
```

Run with graphical installer:
```
qemu-system-x86_64 \
    -m 4096 -cpu host -smp 4 \
    -device virtio-vga -display sdl \
    -device virtio-keyboard-pci -device virtio-mouse-pci \
    -nic user,model=virtio-net-pci \
    -drive file="/path/to/your/vm/nixos.qcow2",if=virtio,format=qcow2 \
    -cdrom "/path/to/your/iso/nixos-installer.iso" \
    -boot d \
    -bios /path/to/your/ovmf/OVMF_CODE.fd \
    --enable-kvm
```
If you have trouble with the mouse (jittering, too fast, unresponsive), try switching the display to `-display gtk,gl=on`. This should work with no problem on Linux. The command would look something like:

```
qemu-system-x86_64  \
	-m 4096 -cpu host -smp 4 \
	-display gtk,gl=on \
	-device virtio-vga \
	-device virtio-keyboard-pci \
	-device virtio-mouse-pci \
	-nic user,model=virtio-net-pci \
	-drive file="/path/to/your/vm/nixos.qcow2",if=virtio,format=qcow2 \
    -cdrom "/path/to/your/iso/nixos-installer.iso" \
    -boot d \
    -bios /path/to/your/ovmf/OVMF_CODE.fd \
    --enable-kvm
```

Change the drive file="...",-cdrom "..." and -bios "..." arguments to paths to your files on your system.
The `OVMF_CODE.fd` file should be located at `/usr/share/edk2/ovmf/OVMF_CODE.fd`. If not just download it [here](https://github.com/kholia/OSX-KVM/raw/refs/heads/master/OVMF_CODE.fd) and pass the path to the file in the `-bios` argument.

Now you are in a graphical installer and the rest should be quite straightforward. Follow the graphical installation manual. Once you are done you can shut down the virtual machine (either manually through the guest system or just close the QEMU window). At this point NixOS should be installed on your virtual drive (`your_drive.qcow2`).

After installation you don't have to include the installation iso:
```
qemu-system-x86_64 \
    -m 4096 -cpu host -smp 4 \
    -device virtio-vga -display sdl \
    -device virtio-keyboard-pci -device virtio-mouse-pci \
    -nic user,model=virtio-net-pci \
    -drive file="/path/to/your/vm/nixos.qcow2",if=virtio,format=qcow2 \
    -boot d \
    -bios /path/to/your/ovmf/OVMF_CODE.fd \
    --enable-kvm
```
Again change the `drive file="..."` and `-bios "..."` arguments. This should boot up virtual machine with NixOS installed.

If you are having problems running QEMU, try manually enabling the libvirtd service.
```
sudo systemctl enable --now libvirtd
```

### 1.5 Dualbooting with Windows

TODO

## 2. First login <a name="first-login"></a>
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

## 3.1 Setting up git and github <a name="git"></a>
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

## 3.2 Flakes <a name="flakes"></a>

I'm currently in the process of reading [NixOS & Flakes Book - An unofficial book for beginners](https://nixos-and-flakes.thiscute.world/) because I feel like flakes are a bit advanced topic and I don't want to get things wrong. Once I feel more confident I will complete this section.

## 3.3 Home-manager <a name="home-manager"></a>

### 3.3.1 Plasma-manager <a name="plasma-manager"></a>

Plasma-manager is a tool for managing your KDE configuration declaratively.

## 4. Desktop environment <a name="desktop-environment"></a>

### 4.1 KDE <a name="desktop-environment-kde"></a>

### 4.2 Sway <a name="desktop-environment-sway"></a>

Both Sway and Hyprland are a bit more complicated than a simple KDE. They are not a desktop environments as per se. Officialy they are "window managers". That basically means that you have to configure everything else yourself - from lock screen to taskbar.

### 4.3 Hyprland <a name="desktop-environment-hyprland"></a>

## 5. NixOS optimizations <a name="nixos-optimizations"></a>

### 5.1 Optimizing storage

You can remove all but the current generation using the command `sudo nix-collect-garbage -d`. This is especially useful on devices with lower total storage space (like Raspberry Pi). To also remove unused store paths run `nix-store --gc`.

If you want to keep only the last three generations and delete the other use the command `nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system`.

Setting a maximum number of stored generations can be done by applying following settings in your nix configuration:

```
boot.loader.generations = 3; # keeps only last three generations
```
