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

# Cross-platform

firefox
zed
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
