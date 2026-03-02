# Set up Git

Generate SSH key:

```sh
ssh-keygen -t ed25519
```

View the public key:

```sh
cat ~/.ssh/id_ed25519.pub
```

# Swappiness

The default value of [swappiness] is too high (60), to change it to the recommended 10:

```sh
sudo -E vim /etc/sysctl.conf
# add this line: vm.swappiness=10
sudo sysctl --load=/etc/sysctl.conf
# now, reboot
```

[swappiness]: https://askubuntu.com/questions/157793/why-is-swap-being-used-even-though-i-have-plenty-of-free-ram

# virtul machine management

List available VMs:

```sh
virsh list
```

## Open VM

Start up the VM:

```sh
virsh start DOMAIN
```

Find the display port of the VM:

```sh
virsh domdisplay DOMAIN
```

Open the VM in a window:

```sh
remote-viewer DISPLAY_PORT
```

If VM on windows has low resolution: https://superuser.com/a/1822071

## Power

Shutdown the VM:

```sh
virsh shutdown DOMAIN
# alternative (force): virsh destroy DOMAIN
```

Reboot:

```sh
virsh reboot DOMAIN
```

## State

Save all state to a file:

```sh
virsh save DOMAIN save_file.save
```

Restore from state file:

```sh
virsh restore save_file.save
```

```sh
virsh domrename DOMAIN new_domain_name
```

# Windows

```sh
scoop bucket add extras
scoop bucket add versions
```

# Cross-platform

zed-nightly (pacman: zed-preview-bin)
nushell
vim
bat
just
zoxide
ripgrep
delta (pacman: git-delta)
hyperfine
vivid
lazygit
mpv
carapace-bin
mergiraf

sccache

# Cross-platform, language-specific

rust
nodejs

# Linux only

vulkan-intel (for Intel + Zed)
nautilus
openssh

# Fonts (pacman)

noto-fonts-cjk
noto-fonts-emoji
noto-fonts
ttf-jetbrains-mono
ttf-jetbrains-mono-nerd

# Cargo

cargo-outdated
cargo-expand
live-server
