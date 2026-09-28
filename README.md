# dotfiles

My system config, shared between:

- Linux (Fedora COSMIC Atomic)
- macOS
- Windows

On a fresh machine I run one command, and it installs my programs and puts
all the config files where they belong.

## Install

On Linux (Fedora COSMIC Atomic) and macOS:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /tmp init --apply --use-builtin-git=true nik-rev
```

On Windows, in PowerShell:

```powershell
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b '$env:TEMP' init --apply nik-rev"
```

Expect some UAC prompts on Windows. On macOS, a dialog asks to install the
Command Line Tools, so click "Install".

<details>
<summary>What the command does</summary>

1. Downloads chezmoi to a temporary directory
2. Clones this repository to `~/.local/share/chezmoi`
3. Runs `chezmoi apply`, which does everything in
   [What happens during setup](#what-happens-during-setup)

The `--use-builtin-git` flag is there because chezmoi has to clone the repo
before git is installed. On a fresh Mac, `git` is just a placeholder that
offers to install the developer tools.

</details>

## How it works

Two tools do all the work:

- **chezmoi** manages the dotfiles
- **pixi** installs the programs

### chezmoi

[chezmoi](https://chezmoi.io) copies the files in this repository into my
home directory. The repo lives in `~/.local/share/chezmoi`, and the file
names tell chezmoi where everything goes:

- `dot_config/nushell/config.nu` ends up as `~/.config/nushell/config.nu`.
  The `dot_` prefix turns into a leading `.`.
- Files ending in `.tmpl` are templates, so they can be different per
  platform, e.g. `{{ if eq .chezmoi.os "windows" }}...{{ end }}`.
- Prefixes like `executable_` and `symlink_` set file attributes.
- [`.chezmoiignore`](.chezmoiignore) lists what a platform shouldn't get,
  like the COSMIC config on macOS.
- [`.chezmoiscripts/`](.chezmoiscripts) has the setup scripts that install
  programs. The ones named `run_onchange_...` only run again when their
  content changes, which includes changes to a package list they pull in.
- [`.chezmoidata/`](.chezmoidata) holds data for the templates, such as
  package lists.
- [`.chezmoiexternal.toml.tmpl`](.chezmoiexternal.toml.tmpl) lists files for
  chezmoi to download, such as fonts and the Lockbook CLI.

Running `chezmoi apply` makes the home directory match the repository.

### pixi

[pixi](https://pixi.sh) is a package manager that works the same way on
Linux, macOS and Windows. It gets its packages from
[conda-forge](https://conda-forge.org), a big repository of prebuilt
programs and libraries for all three, and installs them into the home
directory. It doesn't need admin rights and doesn't touch the rest of the
system.

Every set of packages goes into its own **environment**, which is just a
directory containing those packages and nothing else. I use two kinds:

- **Global tools.** Each CLI tool (nushell, ripgrep, bat, etc.) gets its
  own environment, and pixi puts its commands in `~/.pixi/bin`. That's on
  the PATH, so they work everywhere. They're all listed in pixi's own file,
  `~/.pixi/manifests/pixi-global.toml`, and `pixi global sync` installs
  exactly what's in there.
- **Workspaces.** These are described by a `pixi.toml`, and their commands
  are only available after entering them with `pixi shell`. My Rust setup
  is one of these (see [Rust](#rust)).

To get rid of an environment, delete its directory. pixi also keeps a cache
of downloaded packages, and `pixi clean cache` empties it.

### What each platform gets

| | Fedora Atomic | macOS | Windows |
|---|---|---|---|
| CLI tools | pixi | pixi | pixi |
| Zed | pixi | pixi | pixi |
| Alacritty | pixi | pixi | pixi |
| Other apps | Flathub | downloaded from the developers | winget |
| Rust | pixi workspace | pixi workspace + Xcode Command Line Tools | pixi workspace + Visual Studio Build Tools |
| Fonts | `~/.local/share/fonts` | `~/Library/Fonts` | per-user fonts |

conda-forge doesn't have many graphical apps, and only Apple and Microsoft
ship their compilers, so those parts are different on each platform. On
Fedora Atomic, the only packages layered with `rpm-ostree` are ones the
COSMIC image is missing. On other Linux distros, only the config files get
installed.

### Why Zed and Alacritty come from pixi

On Fedora Atomic, my other graphical apps come from Flathub and each one
runs in a sandbox. That's fine for apps that just open files, but it doesn't
work well for these two.

Zed runs language servers, `cargo` and a terminal with my shell, and all of
those live outside a flatpak's sandbox. The flatpak version needed a bunch
of workarounds to reach them. Installed with pixi, it's just a normal
desktop app that finds everything on its own.

Alacritty isn't on Flathub at all, which makes sense: if the terminal were
sandboxed, the shell inside it would be too.

pixi also adds both apps to the app menu (that's what `shortcuts` in the
manifest does), and the same package works on every platform. The one
exception is Zed on Windows, which gets no Start menu entry from pixi. Setup
adds one there, and also registers `zed://` links the way Zed's own
installer would. Zed 1.21 can't actually open `zed://file` links on Windows
yet, though, no matter how it's installed.

Note that conda-forge only has Zed's stable releases, not Zed Preview.

### What happens during setup

`chezmoi apply` goes through these steps in order:

1. **Install whatever pixi can't**
   ([`install-packages`](.chezmoiscripts)):

   - Flathub apps on Fedora Atomic
   - the Xcode Command Line Tools and apps like Blender on macOS
   - winget packages and the Visual Studio Build Tools on Windows
   - and finally pixi itself

2. **Put the config files in place** and download the fonts.
3. **Install the global tools** with `pixi global sync` (`pixi-global-sync`).
4. **Install Rust** into its pixi workspace (`install-rust`).

If I run it again, it only redoes what changed.

## Installing packages

### CLI tools (all platforms)

1. Look the package up on conda-forge, either with `pixi search <name>` or
   on [prefix.dev](https://prefix.dev/channels/conda-forge).
2. Open the list:

   ```sh
   chezmoi edit ~/.pixi/manifests/pixi-global.toml
   ```

   This actually edits the template in the repo,
   [`dot_pixi/manifests/pixi-global.toml.tmpl`](dot_pixi/manifests/pixi-global.toml.tmpl).

3. Add an environment for the package. In `exposed`, each key is a command
   to put on the PATH, and its value is the command inside the package:

   ```toml
   [envs.fd-find]
   channels = ["conda-forge"]
   dependencies = { fd-find = "*" }
   exposed = { fd = "fd" }
   ```

   Every exposed command has to exist in the package on every platform that
   gets it, or `pixi global sync` will fail. The easiest way to find out
   what a package provides is to install it once with
   `pixi global install <package>`. It prints the commands it exposes and
   writes a ready-made entry into `~/.pixi/manifests/pixi-global.toml` that
   I can copy.

4. If a package is only for one platform, wrap it in a template condition,
   like the uutils entry for Windows:

   ```toml
   {{- if eq .chezmoi.os "windows" }}
   [envs.uutils-coreutils]
   …
   {{- end }}
   ```

   `.chezmoi.os` is one of `linux`, `darwin` or `windows`.

5. Run `chezmoi apply`. It sees that the list changed and runs
   `pixi global sync`.

6. Commit and push, and the other machines pick it up with
   `chezmoi update`.

Removing a tool works the same way: delete its entry and run
`chezmoi apply`.

Don't use `pixi global install` for tools you want to keep, because the
next `chezmoi apply` resets the list to what's in the repository and
removes them again.

### Apps and other packages

| What | Where |
|---|---|
| Flathub apps (Fedora Atomic) | [`flatpaks.txt`](flatpaks.txt). Install the app with `flatpak --user install flathub <app>`, then run `sh sync-packages.sh` to update the list |
| Flathub extensions (Fedora Atomic) | `fedora.flatpak_extensions` in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml). `sync-packages.sh` only picks up apps, so these go here |
| Layered packages (Fedora Atomic) | `fedora.layered` in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml). Only for things the COSMIC image doesn't ship yet. Setup reminds me to remove one once Fedora includes it |
| winget packages (Windows) | `windows.winget` in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml). Apps that are only in the Microsoft Store, like Lockbook, go in `windows.msstore` with their Store ID |
| Apps (macOS) | The "macOS applications" part of [`install-packages`](.chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl), which downloads them from their developers. There's no package manager for these, so each app is a line in the script |
| Rust components, `cargo install` tools | `rust` in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml) |
| Libraries and tools for compiling Rust | [`dot_local/share/rust-env/pixi.toml`](dot_local/share/rust-env/pixi.toml) |

`chezmoi apply` installs whatever changed in any of these.

## Rust

Everything I need to compile Rust lives in one pixi workspace,
`~/.local/share/rust-env`:

- nightly Rust from rustup, plus any toolchains that projects pin in their
  `rust-toolchain.toml`
- cargo's [config](dot_local/share/rust-env/cargo/config.toml), its
  downloads, and whatever I install with `cargo install`
- sccache and its cache
- on Linux, the C compiler, linker and libraries (like OpenSSL) that crates
  with C code need

None of it leaks outside that directory, so `cargo` doesn't even exist
until I enter the environment:

```sh
rust    # alias for: pixi shell --manifest-path ~/.local/share/rust-env/pixi.toml
cargo build
```

Zed doesn't need me to enter it, because `~/.local/bin/rust-analyzer` runs
rust-analyzer from the environment.

To remove Rust completely, I'd set `rust.enabled = false` in
[`.chezmoidata/packages.toml`](.chezmoidata/packages.toml) and delete
`~/.local/share/rust-env`.

My cargo config uses cranelift for debug builds, so projects that pin their
own toolchain need the cranelift component added to it. From inside the
project, in the environment, run
`rustup component add rustc-codegen-cranelift-preview`.

## Virtual machines

On Fedora Atomic, I run Linux and Windows virtual machines with
[virt-manager](https://virt-manager.org) and its QEMU extension, both from
Flathub. Nothing gets installed on the system itself. The VMs run as my
user (the "QEMU/KVM User session" connection in virt-manager), and KVM
keeps them as fast as usual.

- **Windows 11** needs UEFI firmware and a TPM. When creating the VM, tick
  "Customize configuration before install", set the firmware to UEFI and
  add a TPM device (emulated, TPM 2.0). Or from the command line:

  ```sh
  flatpak run --command=virt-install org.virt_manager.virt-manager \
      --connect qemu:///session --name win11 --osinfo win11 \
      --memory 8192 --vcpus 4 --boot uefi \
      --tpm model=tpm-crb,backend.type=emulator,backend.version=2.0 \
      --disk size=80 --cdrom ~/Downloads/Win11.iso --network user
  ```

- **Networking** is NAT only. The VMs can reach the internet, but the host
  can't reach them by IP, and bridged networking isn't available.
- **Disks** are stored in
  `~/.var/app/org.virt_manager.virt-manager/data/images`. virt-manager can
  open ISOs from `~/Downloads` and the other home folders.
- **`virsh`** works through
  `flatpak run --command=virsh org.virt_manager.virt-manager --connect qemu:///session`.

## NVIDIA graphics

This isn't part of the setup, since it depends on the hardware. On Fedora
Atomic, NVIDIA's driver comes from
[RPM Fusion](https://rpmfusion.org/Howto/NVIDIA), which uses NVIDIA's open
kernel module for GeForce RTX 20 and newer.

1. Add RPM Fusion and reboot:

   ```sh
   sudo rpm-ostree install \
       https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
       https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
   systemctl reboot
   ```

2. Install the driver, turn off the drivers Fedora ships with, and reboot
   again:

   ```sh
   sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia
   sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core \
       --append=modprobe.blacklist=nouveau,nova_core
   systemctl reboot
   ```

   For CUDA and `nvidia-smi`, add `xorg-x11-drv-nvidia-cuda` to the first
   command.

3. Check that it's being used with `cat /proc/driver/nvidia/version`.

If Secure Boot is on, the driver has to be signed first. RPM Fusion's
[Secure Boot guide](https://rpmfusion.org/Howto/Secure%20Boot) explains how.
On laptops with a GeForce RTX 30 or newer, the NVIDIA GPU switches itself
off when it's idle. The driver gets rebuilt on every system update, so
updates take longer.

secureblue has images with NVIDIA's driver already built in
(`cosmic-nvidia-open`), so none of this is needed there.

## Everyday use

```sh
chezmoi edit ~/.config/nushell/config.nu  # edit a config file
chezmoi apply                             # apply changes from the repository
chezmoi update                            # pull from GitHub, then apply
chezmoi add ~/.config/some/file           # start managing a new file
chezmoi diff                              # what `chezmoi apply` would change
chezmoi cd                                # open nushell in the repository
```

### Updating

```sh
chezmoi update       # new dotfiles from GitHub, including new packages
pixi global update   # newer versions of the pixi tools, like Zed
rpm-ostree upgrade   # Fedora Atomic itself, then reboot
```

`chezmoi apply` installs things that are missing, but it never updates what's
already installed. The one exception is the Lockbook CLI, which it
downloads again once a week.

`flatpak update` updates the Flathub apps on Fedora, and on Windows,
`winget upgrade --all` updates everything from winget and the Microsoft
Store. The apps I download on macOS (Blender and Lockbook) don't
update themselves. To update one, I delete it from `/Applications` and run
the setup scripts again:

```sh
chezmoi state delete-bucket --bucket=entryState
chezmoi apply
```

### Backing up Lockbook

The `lockbook` CLI gets installed on every platform (on Linux, only on
x86_64, since there's no ARM build). I use it to back up my notes. It
keeps its own copy of them in `~/.lockbook`, separate from the desktop
app's, so it needs to be logged in once on each machine with
`lockbook account import`, using my account key or 24-word phrase. After
that, a backup is:

```sh
lockbook sync                         # get the latest notes
lockbook export <folder> <backup-dir> # copy them to the backup
```

### SSH keys

My SSH keys have a passphrase, so the key files are useless to anyone who
copies them. To avoid typing it all the time, ssh hands the key to
ssh-agent the first time I use it, and the agent keeps it for a day
(`AddKeysToAgent 24h` in [`~/.ssh/config`](private_dot_ssh/config)).
Logging out or rebooting clears it sooner.

In practice, I type the passphrase once a day:

- `git` in a terminal asks for it directly.
- lazygit shows a popup for it when pushing or pulling. Its automatic
  background fetch never asks, it just skips fetching until the key is
  loaded.
- Zed asks in a window of its own.

On Fedora, the dotfiles turn on the ssh-agent that Fedora ships but leaves
off, and point `SSH_AUTH_SOCK` at it in `~/.bashrc.d`, so apps started from
the desktop find it too (log out and back in after the first setup). macOS
has an agent running already. On Windows, setup turns on the agent that
comes with Windows, and git uses Windows' own `ssh` so it can reach it.

Windows' agent is different: it refuses keys with a time limit, so it
keeps the key for good, saved encrypted with my Windows login, until I
remove it with `ssh-add -D`. I type the passphrase once, not once a day.

```sh
ssh-keygen -t ed25519               # new key; it asks for a passphrase
ssh-keygen -p -f ~/.ssh/id_ed25519  # add or change the passphrase of a key
ssh-add -l                          # which keys the agent has right now
ssh-add -D                          # forget them now
```

While a key is loaded, a program running as me could ask the agent to use
it, but it can't copy the key out of the agent.

## Platform details

### Config locations

The config files live in `~/.config` on every platform. Some apps look
somewhere else on macOS (`~/Library/Application Support`) and Windows
(`AppData`), so I link those locations to `~/.config` and the apps find
their config anyway:

- On macOS, with symlinks, the same as on Linux.
- On Windows, with junctions, which are Windows' version of a link for
  folders. `AppData\Roaming\Zed` becomes another name for `~\.config\zed`,
  and programs see the same files through both paths. Creating a junction
  doesn't need admin rights, unlike a symlink, and deleting one only
  removes the link, not the files behind it.

### The `zed` command

`zed` opens Zed from a terminal on every platform. pixi provides it.

### Automatic login on Fedora Atomic

The disk encryption password at boot is the only password I type. After
that, COSMIC logs me in by itself. To turn this off, set `login.autologin`
in [`.chezmoidata/desktop.toml`](.chezmoidata/desktop.toml). Changing it
makes `chezmoi apply` ask for the sudo password.

Normally the keyring, where apps like Zed and git store passwords, unlocks
with the login password. With automatic login there isn't one, so instead it
unlocks with a random password that systemd stores encrypted, readable only
on this machine. The keyring stays encrypted on disk, and I never get asked
for its password. This only works with a keyring that these dotfiles
created. If one already exists, setup explains what to do.

### Layered packages on Fedora Atomic

One package gets layered onto the system image, because the COSMIC image
doesn't ship it yet: `oo7-portal`. It lets flatpak apps store passwords
in the keyring. Once Fedora adds it to the image, it won't
be needed anymore, and setup will remind me to remove it from
`fedora.layered` and run `rpm-ostree uninstall oo7-portal`.

### uutils on Windows

uutils provides `ls`, `cp`, `cat` and the rest of the coreutils. Windows' own
`expand`, `hostname`, `more`, `sort`, `timeout` and `whoami` come first on
the PATH, though. In nushell, its built-in commands like `ls` also win, so
call the uutils version with a caret, like `^ls`.

## secureblue

[secureblue](https://secureblue.dev) is a hardened version of Fedora Atomic,
and these dotfiles also work on its COSMIC image (`cosmic-main-hardened`).
Install Fedora Atomic first, rebase to secureblue following its guide, and
then run the usual install command. A few things are different:

- There's no `sudo` on secureblue. Setup uses `run0` instead, which asks for
  the password every single time.
- It's based on an older Fedora that uses gnome-keyring instead of oo7. With
  automatic login, gnome-keyring asks for the login password the first time
  an app needs it.
- `oo7-portal` doesn't get layered, because gnome-keyring already acts as
  the Secret portal.
- The firewall blocks incoming connections and SSH is turned off. That only
  matters for remote access.

### Migrating to secureblue (planned)

I plan to move to secureblue once it's based on a Fedora that ships
oo7-portal in the image. At that point nothing has to be layered anymore,
and the keyring should unlock by itself after automatic login, like it does
on Fedora 45 today. Setup will let me know when Fedora's image includes
oo7-portal ("Fedora's image now includes oo7-portal").

1. Undo the things secureblue already provides:
   - `rpm-ostree uninstall oo7-portal`
   - the NVIDIA driver from RPM Fusion, if it's installed. secureblue's
     `cosmic-nvidia-open` image comes with it, signed for Secure Boot, so
     uninstall the packages and remove the kernel arguments from
     [NVIDIA graphics](#nvidia-graphics).
2. Switch over, as described in
   [secureblue's guide](https://secureblue.dev/install), and reboot:

   ```sh
   sudo bootc switch ghcr.io/secureblue/cosmic-main-hardened:latest
   ```

3. Go through secureblue's
   [post-install steps](https://secureblue.dev/post-install).
4. Run `chezmoi apply`, and then check two things:
   - Apps started from the desktop can still find the pixi tools (Alacritty
     should start nushell). secureblue has an optional bash environment
     lockdown that can stop `~/.bashrc.d` from loading, and that's where
     this PATH comes from.
   - If I set up a separate admin account (`ujust create-admin`), setup's
     `run0` will ask for the admin password instead of mine.

Nothing in the home directory changes, so the dotfiles, pixi, Rust and the
keyring all stay as they are.

## Troubleshooting

**A setup script failed.** Fix whatever caused it and run `chezmoi apply`
again. Scripts that already succeeded get skipped.

**Run all the setup scripts again**, e.g. after deleting an environment:

```sh
chezmoi state delete-bucket --bucket=entryState
chezmoi apply
```

**A tool is missing** right after installing it: open a new terminal so it
picks up the new PATH.

## Layout

| Path | Contents |
|---|---|
| `dot_config/` | config files, installed to `~/.config` |
| `dot_pixi/manifests/` | global CLI tools, for pixi |
| `dot_local/share/rust-env/` | the Rust workspace, including cargo's config |
| `dot_local/bin/` | `rust-analyzer` from the Rust workspace |
| `dot_bashrc.d/` | Linux: the PATH and the SSH agent for the desktop session |
| `private_dot_ssh/config.tmpl` | keeps SSH keys in the agent (for a day, except on Windows) |
| `.chezmoidata/packages.toml` | packages pixi doesn't provide |
| `.chezmoidata/desktop.toml` | desktop settings, like automatic login |
| `.chezmoiscripts/` | setup scripts |
| `.chezmoitemplates/` | pieces shared by templates and scripts |
| `.chezmoiexternal.toml.tmpl` | downloaded files: fonts and the Lockbook CLI |
| `.chezmoiignore` | which files each platform gets |
| `Library/` | macOS: links app config locations to `~/.config` |
| `flatpaks.txt`, `sync-packages.sh` | Flathub apps, and a script to update the list |
