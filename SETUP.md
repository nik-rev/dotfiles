# Directories

- `w`: Work stuff
- `p`: Personal projects
- `c`: Contributions to other people's projects
- `t`: Temporary folder, may be `rm rf`d at any time

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
virsh list --all
```

List available networks:

```sh
virsh net-list --all
```

Turn on the `default` network:

```sh
virsh net-start default
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
fish (shell for completions)

# Rust

On windows, install Visual Studio C++ Build Tools

package: rust

# Windows only

coreutils

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
cargo-reedme
live-server

# Linux Fonts

This repository contains a bunch of fonts for a working system: <https://github.com/hazelshantz/Font-Collection/tree/main>
