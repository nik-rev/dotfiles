# Nik's NixOS Dotfiles

I like simple and reliable configs, preferably 1 file for each software

Why I'm using Nix:

- Things never break, and if they do its easy to roll back
- Easy to build software from source with flakes
- Using a programming language for configuration is really powerful

## Wifi Connection on the installation media

Find out SSID and INTERFACE with:

```bash
iwlist scan | grep ESSID && ip link
```

Generate WiFi configuration and connect to wifi:

```bash
wpa_passphrase SSID PASSWORD > /etc/wpa_supplicant.conf
wpa_supplicant -B -i INTERFACE -c /etc/wpa_supplicant.conf
```

## Installation

Become root:

```sh
sudo passwd root
su
```

Partition drives:

```bash
sgdisk -Z -n1:0:+512M -t1:ef02 -c1:boot -N2 -t2:8309 -c2:root /dev/sdX
```

Luks setup:

```bash
cryptsetup luksFormat /dev/disk/by-partlabel/root
cryptsetup luksOpen /dev/disk/by-partlabel/root cryptroot
```

Set up logical volumes:

```bash
pvcreate /dev/mapper/cryptroot
vgcreate vg /dev/mapper/cryptroot
lvcreate -L 8G -n swap vg
lvcreate -l '100%FREE' -n root vg
```

Format partitions:

```bash
mkfs.fat /dev/disk/by-partlabel/boot
mkfs.ext4 -L root /dev/vg/root
mkswap -L swap /dev/vg/swap
```

Mount the partitions

```bash
mount /dev/vg/root /mnt
mkdir /mnt/boot
mount /dev/disk/by-partlabel/boot /mnt/boot
swapon /dev/vg/swap
```

Install nixOS

```bash
git clone https://github.com/nik-rev/dotfiles.git /mnt/etc/nixos
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hardware.nix
nixos-install -v --flake /mnt/etc/nixos#nixos
reboot
```

## Booting from the live media

In order to fix problems, you can launch from the live media

```sh
sudo passwd root
su
cryptsetup luksOpen /dev/disk/by-partlabel/root cryptroot
vgchange -ay vg
mount /dev/vg/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-partlabel/boot /mnt/boot
```

## Set up Git

Generate key

```
ssh-keygen -t ed25519
```

Paste into GitHub

```
cat ~/.ssh/id_ed25519.pub
```
