# NixOS configuration

This is my personal configuration for NixOS. I will most likely split this to multiple repositories or
branches for my server/workstation/other... I've also tried writing up a small tutorial for my first
installation of NixOS. 

See the [Manual](#Manual) section if this is your first time installing NixOS.

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

        nextcloudPass = "NEXTCLOUD_ADMIN_PASSWORD";

        apiNasaKey = "NASA_API_KEY";
        ...
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

I hope that this secret management is only temporary and that I will be brave enough to learn and implement sops-nix ;).

# Resources

Before you dive into the world of NixOS, I recommend looking at a small list of resources/links/books I've compiled over my period of learning and configuring NixOS. You can find the complete list in the [Resources](#resources-detailed) section.

What you will find there is a mix of my bookmarks, videos, blogs, books and other media I found to be useful when learning NixOS.

In general my main sources of information include (in no particular order):

- [NixOS package search](https://search.nixos.org/packages)
    - For when you need to check package availability or some basic options.
- [NixOS manual](https://nixos.org/manual/nixos/stable/)
    - More in-depth content about the OS, packages and settings. For me this was kind of the thing I went to when I was lost configuring something.
- [nix.dev](https://nix.dev/)
    - Official documentation for the Nix ecosystem.
- [NixOS Wiki](https://wiki.nixos.org/wiki/NixOS_Wiki)
    - Official NixOS Wiki
- [MyNixOS search](https://mynixos.com/)
    - This website provides very nice compilation of all options of any package in NixOS. Even though its base function is probably more complex (I believe they have something like development environments - which I don't use) it is a great resource for anything configuration-related.
- [Vimojer's youtube videos](https://www.youtube.com/@vimjoyer/videos)
    - He's honestly the G.O.A.T of NixOS when it comes to anything. I've watched almost every single one of his videos which are not only informative but also entertaining as well.

*And a word for the AI users out here - please be careful when using tools like ChatGPT or Deepseek. They will often tell you to execute commands that will make your PC automatically non-declarative (usually running `nix-env`). Please be careful with these commands as they might provide temporary fix at the cost of being non-declarative changes. A good rule of thumb for beginners is that if your change does not require the `nixos-rebuild` then it is most likely not declarative (and whats the point of that, am I right ;). Otherwise I think you will probably have a hard time breaking something - NixOS is quite robust by design with its `generations` you can roll back to.*

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
    1. [Wayland compositors](#wayland-compositors)
    1. [Hyprland](#wayland-compositor-hyprland)
    1. [Sway](#wayland-compositor-sway)
    1. [Mango](#wayland-compositor-mango)
1. [NixOS optimizations](#nixos-optimizations)
1. [Resources](#resources-detailed)

## 1. Installation <a name="installation"></a>

You will generally want to follow the [installation for x86-64 system](#11-manual-installation-on-x86-64-system) if you have something like desktop PC or laptop. If you have more specialized hardware, such as Raspberry Pi, your installation might look a bit different. I have so far only installed NixOS on Raspberry Pi 3B. To install NixOS on Raspberry Pi (3B) follow the [Raspberry Pi](#12-raspberry-pi-3b) manual.

When installing NixOS in an virtual environment (such as in Virtualbox or VMware) be careful of the settings. I tried installing and running this config in both Virtualbox and VMware, both were quite a pain in the ass when working on Windows. Running this configuration in Virtualbox on Linux (Fedora 42) was easy and painless (damn you Windows!).

Be sure to enable EFI when creating the machine (this configuration probably won't work without EFI enabled). On Virtualbox I experienced brutal graphical lags when running KDE Plasma 6. I fixed this by switching to older graphics controller (VBoxSVGA or VBoxVGA). The newer graphics controller (VMSVGA) did not work, I was getting tons of visual glitches and the interface was so laggy I could not get anything done.

VMware seemed to run much smoother, altough at the time of writing this I have not figured out how to enable EFI in the settings.

If you plan on running any **Wayland** compositor such as **Sway** or **Hyprland** and want to run **NixOS in virtual machine on Windows**, **I strongly recommend** using [QEMU](https://www.qemu.org/) - see section [installing NixOS on QEMU virtual machine](#13-Installing-NixOS-on-virtual-machine-on-Windows-host-using-QEMU). I have not been able to run any Wayland compositor through Virtualbox or VMware on Windows. This tutorial might be a bit advanced than just using Virtualbox or VMware, but you should be able to customize the virtual machine more and mainly, as previously stated, be able to run **Wayland**.

### 1.1 Manual installation on x86-64 system <a name="installation"></a>

Just recently I found `sudo nix run github:km-clay/nixos-wizard --extra-experimental-features nix-command --extra-experimental-features flakes` command that runs TUI (terminal user interface) installer, maybe give it a try or follow the manual installation.

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
    -accel whpx -M q35 ^
    -m 4096 -cpu max -smp 4 ^
    -device qxl-vga,vgamem_mb=4096 ^
    -device virtio-keyboard-pci -device virtio-mouse-pci ^
    -netdev tap,id=mynet0,ifname="Ethernet 3",script=no,downscript=no ^
    -device virtio-net-pci,netdev=mynet0 ^
    -usb -device usb-tablet ^
    -drive file="C:\Path\to\vm\nixos.qcow2",if=virtio,format=qcow2 ^
    -bios "C:\Path\to\qemu\OVMF_CODE.fd"
```

Change the `ifname` in `-netdev` argument to the name of your network adapter.
This runs much smoother by using the `-accel whpx` and `-device qxl-vga`. If all you see is black screen try resizing the QEMU window few times.

3. my cursor is upside down

To fix the goofy bug when your cursor is upside down but everything else looks perfect, you can try running:

```
qemu-system-x86_64.exe ^
    -accel whpx -M q35 ^
    -m 4096 -cpu max -smp 4 ^
    -device qxl-vga,vgamem_mb=4096 ^
    -device virtio-keyboard-pci -device virtio-mouse-pci ^
    -netdev tap,id=mynet0,ifname="Ethernet 3",script=no,downscript=no ^
    -device virtio-net-pci,netdev=mynet0 ^
    -drive file="C:\Path\to\vm\nixos.qcow2",if=virtio,format=qcow2 ^
    -bios "C:\Path\to\qemu\OVMF_CODE.fd"
```

AND before running `sway` or `hyprland` be sure to run `export WLR_NO_HARDWARE_CURSORS=1` (or set the environment variable somewhere).

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

Home-manager lets you manage user files (typically dotfiles) through nix configuration. This can be quite nice if you have a certain themes, keybinds or other settings you want to apply to multiple programs at once in your nix configuration.

In the most basic use, you can just copy a dotfiles directory (or repository) to your `.config` home folder. This is what I'm currently doing and I find it to be the easiest way to manage your dotfiles. There are many advantages to using fully declarative dotfiles through home-manager and nix. For more information about this I recommend [Vimjoyer's video about home-manager](https://youtu.be/FcC2dzecovw?si=wpAe9nwFCOXFvOIe).

### 3.3.1 Plasma-manager <a name="plasma-manager"></a>

Plasma-manager is a tool for managing your KDE configuration declaratively. Unfortunately I found it quite lacking of features and configuration options you can set. One of the reasons I switched to NixOS was that I could have my **whole** computer declarative. The biggest problem with KDE is that the configuration files are scattered across the system. This has been a problem for a long time and I do hope that KDE can fix it. There are also tools such as [Konsave](https://github.com/Prayag2/konsave) which I have not personally used (but might give a try in the future).

## 4. Desktop environment <a name="desktop-environment"></a>

Desktop environment

### 4.1 KDE <a name="desktop-environment-kde"></a>

Installing KDE is as easy as adding these three lines of code to your configuration.

```
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
security.rtkit.enable = true;
```

That's all! Isn't that crazy? And if you want to change this to something else just comment these lines and bring in your own desktop environment.

### 4.2 Wayland compositors <a name="wayland-compositors"></a>

Both Sway and Hyprland (and other compositors such as Mango, Niri, ...) are a bit more complicated than a simple KDE (or is it rather the other way!?). Well for the user is is probably more complicated to get Hyprland or Sway running that KDE. But they are simpler and should have smaller memory and cpu footprint than a big desktop environment (such as KDE). The advantage (and also disadvantage in some cases) is that you have to bring everything else yourself - lock screen, taskbar, file manager and basically everything else you can think of when you think of desktop environment. They are not a desktop environments per se. Officialy they are "window managers". That means they only manage your windows - and that's it. Nothing more, nothing less.

That's also why I will show only the *most basic configuration* of Hyprland and Sway. I'd say that at the point of writing this they are more for power-users.

I noticed that I've been basically using the Hyprland window managing phylosophy on my Windows machine. By using the [Microsofts PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/) (yes, one of the two Microsoft products that don't suck) FancyZones utility, I was basically doing what I could be doing in Hyprland automatically, manually.

### 4.2.1 Hyprland <a name="wayland-compositor-hyprland"></a>

In the end, Hyprland was the window manager I stuck with. In my journey to declarative PC I tried Sway, Hyprland and Mango. Hyprland provides quite a few handy features and feels much more polished than the other wayland compositors I have tried.

I installed Hyprland using the official flake. In your flake inputs add

```
hyprland.url = "github:hyprwm/Hyprland";

### PLUGINS ### you don't really have to install these if you will not be using them
hyprland-plugins = {
    url = "github:hyprwm/hyprland-plugins";
    inputs.hyprland.follows = "hyprland";
};
Hyprspace = {
    url = "github:KZDKM/Hyprspace";
    inputs.hyprland.follows = "hyprland";
};
```

The plugins are configured WITHOUT home-manager and you can see the code snippets on how to get them work in `machines/workstation/hypr.nix`, `dotfiles/hypr/hyprland.conf` and `dotfiles/hypr/modules/plugins.conf`.

Then onto the Hyprland configuration in NixOS. Notice that the package follows the flake repository.

```
programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
};

services.xserver.enable = false;
security.polkit.enable = true;
services.dbus.enable = true;
hardware.graphics.enable = true;

xdg.portal.enable = true;
xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

# QEMU-specific config
services.xserver.videoDrivers = [ "virtio" ];
environment.variables.WLE_NO_HARDWARE_CURSORS = "1";
```

And some packages with that please:

```
# hypr utils
environment.systemPackages = lib.mkAfter(with pkgs; [
    killall
    sddm-astronaut # SDDM login screen

    wev
    wayland
    wlr-randr
    wdisplays
    tuigreet

    hyprpaper
    hypridle
    hyprlock
    waybar
    eww

    grim					# Screenshot utility
    slurp					# Select region for grim
    nwg-wrapper				# Custom widget displayer
    vicinae					# Launcher
    pwvucontrol				# volume and sound control
]);
```

And other configuration, such as pipewire and login screen components:
```
services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    pulse.enable = true;
};

services.xserver.enable = true;
# Login screen using sddm and sddm-astronaut theme
services.displayManager.sddm = {
	enable = true;
	extraPackages = [ pkgs.sddm-astronaut ];
	theme = "sddm-astronaut-theme";
	autoLogin.relogin = false;
	wayland.enable = true;
    # All available settings can be found using the man commang: `man sddm.conf` or online: https://manpages.debian.org/trixie/sddm/sddm.conf.5.en.html
	settings = {
		Autologin = {
			Session = "start-hyprland";
			User = "username"; # Change this to your user name
			Relogin = false;
		};
	};
};

```

### 4.2.2 Sway <a name="wayland-compositor-sway"></a>

When using this configuration, please refer to the `machines/workstation/sway.nix` file (or `modules/de/sway.nix` if you are from the future ;) - yeah I'm too lazy to make my config modular for now).

Installing Sway was quite easy, this config should be all you need.

```
programs.sway.enable = true;
services.xserver.enable = false; # disable X11
security.polkit.enable = true;

# enable hardware acceleration
hardware.graphics = {
    enable = true;
};

# QEMU-specific config
services.xserver.videoDrivers = [ "virtio" ];
environment.variables.WLR_NO_HARDWARE_CURSORS = "1";
```

You will most likely want to use these packages with Sway:

```
# sway utils
environment.systemPackages = lib.mkAfter(with pkgs; [
    wev
    wayland
    wlr-randr

    tuigreet
    swaybg
    swaylock
    swayidle
    sway-launcher-desktop	# TUI application launcher
    grim					# Screenshot utility
    slurp					# Select region for grim
    nwg-panel				# Taskbar
    nwg-wrapper				# custom widget displayer
]);
```

Then bring in other components, such as TUI greeter and more:

```
# graphical login screen (greetd+tuigreet)
services.greetd = {
    enable = true;
    settings = {
        default_session = {
            command = ''
            ${pkgs.tuigreet}/bin/tuigreet --time 
            --theme "border=yellow;text=cyan"
            --remember --remember-session --cmd sway";
            user = "greeter'';
        };
    };
};

# https://github.com/sjcobb2022/nixos-conf/blob/main/hosts/common/optional/greetd.nix
systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StardardError = "journal";
    TTYReset = true;
    TTYYVHangup = true;
    TTYVTDisallocate = true;
};

```


### 4.2.3 Mango <a name="wayland-compositor-mango"></a>

I installed Mango using the official flake. When using this configuration, please refer to the `machines/workstation/mango.nix` file (or `modules/de/mango.nix` if you are from the future ;) - yeah I'm too lazy to make my config modular for now).

Unfortunately, for some reason Mango was the only one that was glitchy as hell on my QEMU virtual machine and nearly unusable. This might have also been one of the reasons I decided to stick with Hyprland for now.

In your flake inputs add:
```
mangowc = {
        url = "github:DreamMaoMao/mango";
        inputs.nixpkgs.follows = "nixpkgs";
    };
```

Then to configure Mango itself...

```
imports = [ inputs.mangowc.nixosModules.mango ];

programs.mango = {
    enable = true;
};

services.xserver.enable = false;
security.polkit.enable = true;
services.dbus.enable = true;
hardware.graphics.enable = true;

# QEMU-specific config
services.xserver.videoDrivers = [ "virtio" ];
environment.variables.WLE_NO_HARDWARE_CURSORS = "1";
```

This is the core of Mango configuration, but you will most likely want some packages with that:

```
environment.systemPackages = lib.mkAfter(with pkgs; [
    foot
    rofi
    waybar
    grim
    slurp
    swaybg
    swaynotificationcenter
    swayidle
    swaylock-effects
    wlogout

    wl-clipboard
    cliphist
    wl-clip-persist

    wlr-randr
    brightnessctl
    wlsunset

    pamixer
    sox
    sway-audio-idle-inhibit

    grim
    slurp
    satty

    swayosd
]);
```

You might want to bring in other components such as TUI greeter:

```
# graphical login screen (greetd+tuigreet)
services.greetd = {
    enable = true;
    settings = {
        default_session = {
            command = ''
            ${pkgs.tuigreet}/bin/tuigreet --time 
            --theme "border=yellow;text=cyan"
            --remember --remember-session --cmd mango";
            user = "greeter'';
        };
    };
};

# https://github.com/sjcobb2022/nixos-conf/blob/main/hosts/common/optional/greetd.nix
systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYYVHangup = true;
    TTYVTDisallocate = true;
};
```

And perhaps a bit of pipewire for your sound card:

```
services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    pulse.enable = true;
};
```

### 5.1 Minecraft Server

An example of running Minecraft server using the PaperMC server package can be found in `machines/server/minecraft-server.nix`. To connect using RCON (Remote Console) you can use programs such as `ARRCON` (Windows) or `rcon-cli` (Linux).

I personally manage the Minecraft server through a Windows machine using `ARRCON`.

```
ARRCON.exe -H SERVER_ADDRESS -P RCON_PORT -p PASSWORD
```

The default port (if unspecified) is `25575`.

## 6. NixOS optimizations <a name="nixos-optimizations"></a>

### 6.1 Optimizing storage

You can remove all but the current generation using the command `sudo nix-collect-garbage -d`. This is especially useful on devices with lower total storage space (like Raspberry Pi). To also remove unused store paths run `nix-store --gc`.

If you want to keep only the last three generations and delete the other use the command `nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system`.

Setting a maximum number of stored generations can be done by applying following settings in your nix configuration:

```
boot.loader.generations = 3; # keeps only last three generations
```

## 7. Resources <a name="resources-detailed"></a>

*If you are from the future I apologize for any dead links :( Please try to find them at [https://web.archive.org/](https://web.archive.org/). Thank you.*

## General NixOS

- [nix-community/nixos-anywhere: Install NixOS everywhere via SSH](https://github.com/nix-community/nixos-anywhere)
- [Misterio77/nix-starter-configs: Simple and documented config templates](https://github.com/Misterio77/nix-starter-configs)
- [NixOS Search - Packages](https://search.nixos.org/packages)
- [MyNixOS](https://mynixos.com/)
- [Matrix - NixOS Wiki](https://nixos.wiki/wiki/Matrix)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/index.html#module-services-matrix)
- [How to setup a Matrix homeserver – /techblog](https://www.redpill-linpro.com/techblog/2025/04/08/matrix-basic-en.html)
- [Appendix A. Plasma-Manager Options](https://nix-community.github.io/plasma-manager/options.xhtml)
- [Packaging existing software with Nix — nix.dev documentation](https://nix.dev/tutorials/packaging-existing-software.html)
- [Installing NixOS on a Raspberry Pi — nix.dev documentation](https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi.html)
- [Introduction to Nix & NixOS | NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/introduction/)
- [Matrix - NixOS Wiki](https://wiki.nixos.org/wiki/Matrix)
- [zupo/nix: My personal notes about playing with NixOS on a Raspberry PI](https://github.com/zupo/nix)
- [Forgejo - NixOS Wiki](https://wiki.nixos.org/wiki/Forgejo)
- [Storage optimization - NixOS Wiki](https://nixos.wiki/wiki/Storage_optimization)
- [Plasma-Manager - NixOS Wiki](https://nixos.wiki/wiki/Plasma-Manager)
- [Preface | NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/preface)
- [Generating an ISO with my entire system configuration inside it : NixOS](https://old.reddit.com/r/NixOS/comments/18lixd3/generating_an_iso_with_my_entire_system/)
- [Friendly reminder: optimize-store is not on by default and you may be using a lot of disk space : NixOS](https://old.reddit.com/r/NixOS/comments/1cunvdw/friendly_reminder_optimizestore_is_not_on_by/)
- [Hyprland on NixOS (w/ UWSM)](https://www.tonybtw.com/tutorial/nixos-hyprland/)
- [SnowflakeOS](https://snowflakeos.org/)
- [mateowoetam/desktop.nix: My Desktop PC NixOS configuration file - Codeberg.org](https://codeberg.org/mateowoetam/desktop.nix)
- [sioodmy/dotfiles: My NixOS configuration flake](https://github.com/sioodmy/dotfiles)
- [JaKooLit/NixOS-Hyprland: Simple and documented config templates to help you get started with NixOS + home-manager + flakes](https://github.com/JaKooLit/NixOS-Hyprland)
- [Declare Firefox extensions and settings - Guides - NixOS Discourse](https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265)

## Gaming

- [Heroic Games Launcher](https://heroicgameslauncher.com/)

## Hyprland

- [hyprwm/hyprpaper: Hyprpaper is a blazing fast wayland wallpaper utility](https://github.com/hyprwm/hyprpaper)
- [Hall of Fame | Hyprland](https://hypr.land/hall_of_fame/)
- [xfcasio/amadeus: Amadeus desktop](https://github.com/xfcasio/amadeus)
- [end-4/dots-hyprland: uhh questioning the meaning of dotfiles](https://github.com/end-4/dots-hyprland?tab=readme-ov-file)
- [hyprland-plugins/hyprbars at main · hyprwm/hyprland-plugins](https://github.com/hyprwm/hyprland-plugins/tree/main/hyprbars)
- [hyprland-community/awesome-hyprland: Awesome list for Hyprland](https://github.com/hyprland-community/awesome-hyprland)
- [caelestia-dots/shell: No waybar here](https://github.com/caelestia-dots/shell)
- [saatvik333/wayland-bongocat: bongocat for your desktop](https://github.com/saatvik333/wayland-bongocat)
- [JakeStanger/ironbar: Customisable Wayland GTK4 bar written in Rust](https://github.com/JakeStanger/ironbar?tab=readme-ov-file)
- [coffeeispower/woomer: Zoomer application for Wayland](https://github.com/coffeeispower/woomer)
- [zakk4223/hyprNStack: Hyprland plugin for N-stack tiling layout](https://github.com/zakk4223/hyprNStack)
- [I may have taken plugins too far... : hyprland](https://old.reddit.com/r/hyprland/comments/11p2chb/i_may_have_taken_plugins_too_far/)
- [elythh/flake: my unavoidable system configuration](https://github.com/elythh/flake)
- [Rastersoft / Desktop Icons NG · GitLab](https://gitlab.com/rastersoft/desktop-icons-ng)
- [atx/wlay: Graphical output management for Wayland](https://github.com/atx/wlay)
- [TypoMustakes/hyprland-toggle-tiling](https://github.com/TypoMustakes/hyprland-toggle-tiling)

## Sway

- [Sway - ArchWiki](https://wiki.archlinux.org/title/Sway)
- [Sway Cheatsheet](https://depau.github.io/sway-cheatsheet/)
- [Useful add ons for sway - swaywm/sway GitHub Wiki](https://github-wiki-see.page/m/swaywm/sway/wiki/Useful-add-ons-for-sway)
- [elkowar/eww: ElKowars wacky widgets](https://github.com/elkowar/eww?tab=readme-ov-file)
- [~whynothugo/wlhc - Wayland hot corners - sourcehut git](https://git.sr.ht/~whynothugo/wlhc)
- [xkeyboard-config-2(7) — Arch manual pages](https://man.archlinux.org/man/xkeyboard-config-2.7.en#LAYOUTS)
- [allie-wake-up/swaycons: Window Icons in Sway with Nerd Fonts](https://github.com/allie-wake-up/swaycons)
- [Ulauncher — Application launcher for Linux](https://ulauncher.io/)
- [Biont/sway-launcher-desktop: TUI Application launcher with Desktop Entry support](https://github.com/Biont/sway-launcher-desktop)
- [hyprwm/hyprpicker: A wlroots-compatible Wayland color picker](https://github.com/hyprwm/hyprpicker)
- [woelper/oculante: A fast and simple image viewer / editor](https://github.com/woelper/oculante)
- [nwg-piotr/nwg-drawer: Application drawer for wlroots-based Wayland compositors](https://github.com/nwg-piotr/nwg-drawer)
- [Geronymos/desktop-icons: Show Files from a Directory on the Desktop](https://github.com/Geronymos/desktop-icons)
- [nwg-piotr/nwg-panel: GTK3-based panel for sway and Hyprland](https://github.com/nwg-piotr/nwg-panel)
- [nwg-shell | Installer & meta-package for the nwg-shell project](https://nwg-piotr.github.io/nwg-shell/)
- [swayr: An urgent-first/most-recently-used window switcher for sway](https://sr.ht/~tsdh/swayr/)
- [bin/i3-fit-floats · master · Robert Hepple / dotfiles · GitLab](https://gitlab.com/wef/dotfiles/-/blob/master/bin/i3-fit-floats)
- [lostatc/swtchr: A pretty Gnome-style window switcher for Sway](https://github.com/lostatc/swtchr)
