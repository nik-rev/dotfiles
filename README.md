# dotfiles

My cross-platform system config for:

- Linux (Fedora COSMIC Atomic)
- macOS
- Windows

A single command sets up a fresh machine: it installs the programs and puts the config files in place.

## Install

- Linux (Fedora COSMIC Atomic)
- macOS

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /tmp init --apply --use-builtin-git=true nik-rev
```

- Windows

```powershell
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b '$env:TEMP' init --apply nik-rev"
```

Windows may show UAC prompts. On macOS, click "Install" when asked to
install the Command Line Tools.

<details>
<summary>What the command does</summary>

1. Downloads chezmoi to a temporary directory
2. Clones this repository to `~/.local/share/chezmoi`
3. Runs `chezmoi apply`, which does everything described in [What happens during setup](#what-happens-during-setup).

`--use-builtin-git` lets chezmoi clone before git is installed. macOS has a
placeholder `git` that only offers to install the developer tools.

</details>

## How it works

- **chezmoi** puts files in place (dotfiles manager)
- **pixi** installs programs (package manager).

### chezmoi: dotfiles manager

[chezmoi](https://chezmoi.io) copies the files in this repository to my
home directory. The repository lives in `~/.local/share/chezmoi`, and file
names say where each file goes:

- `dot_config/nushell/config.nu` becomes `~/.config/nushell/config.nu`
  (`dot_` becomes a leading `.`).
- Files ending in `.tmpl` are templates: they can differ per platform, for
  instance: `{{ if eq .chezmoi.os "windows" }}...{{ end }}`.
- `executable_`, `symlink_` and similar prefixes set file attributes.
- [`.chezmoiignore`](.chezmoiignore) decides which files a platform does
  not get, for example the COSMIC config on macOS.
- [`.chezmoiscripts/`](.chezmoiscripts) contains setup scripts that
  install programs. A script named `run_onchange_...` only runs again when
  its content changes, for example when a package list it includes changes.
- [`.chezmoidata/`](.chezmoidata) holds data the templates use, like
  package lists.
- [`.chezmoiexternal.toml.tmpl`](.chezmoiexternal.toml.tmpl) lists files
  chezmoi downloads, like fonts.

`chezmoi apply` makes the home directory match the repository.

### pixi: package manager

[pixi](https://pixi.sh) is a cross-platform package manager. It installs packages from
[conda-forge](https://conda-forge.org), a large repo of prebuilt
programs and libraries for all three, into the home directory. It needs
no administrator rights and never touches the system.

pixi keeps every set of packages in its own **environment**, a directory
with those packages and nothing else. These dotfiles use two kinds:

- **Global tools**: one environment per CLI tool (nushell, ripgrep, bat,
  etc.). pixi puts the commands of each in `~/.pixi/bin`, which is on the
  PATH, so they work everywhere. All of them are listed in pixi's own file,
  `~/.pixi/manifests/pixi-global.toml`, and `pixi global sync` installs
  exactly what it lists.
- **Workspaces**: an environment described by a `pixi.toml`, whose
  commands are only available after entering it with `pixi shell`. Rust
  lives in one, see [Rust](#rust).

Deleting an environment's directory removes it completely. pixi also
keeps a cache of downloaded packages, which `pixi clean cache` empties.

### What each platform gets

| | Fedora Atomic | macOS | Windows |
|---|---|---|---|
| CLI tools | pixi | pixi | pixi |
| Apps (Zed, ...) | Flathub | Zed's installer | winget |
| Rust | pixi workspace | pixi workspace + Xcode Command Line Tools | pixi workspace + Visual Studio Build Tools |
| Fonts | `~/.local/share/fonts` | `~/Library/Fonts` | per-user fonts |

pixi cannot provide graphical apps, and Apple's and Microsoft's compilers
only come from them, so those stay per platform. On Fedora Atomic, only what the COSMIC image
lacks is layered with `rpm-ostree`. On other Linux
distributions, only the config files are installed.

### What happens during setup

`chezmoi apply` runs, in this order:

1. **Installs what pixi cannot**
   ([`install-packages`](.chezmoiscripts)):

   - Flathub apps on Fedora Atomic
   - Zed and the Xcode Command Line Tools on macOS
   - winget packages and the Visual Studio Build Tools on Windows
   - Then pixi itself.

2. **Puts the config files in place**, and downloads fonts.
3. **Installs the global tools** (`pixi-global-sync`): `pixi global sync`.
4. **Installs Rust** (`install-rust`) into its pixi workspace.

Running it again only does what changed.

## Installing packages

### CLI tools, on every platform

1. Find the package on conda-forge, with `pixi search <name>` or on
   [prefix.dev](https://prefix.dev/channels/conda-forge).
2. Open the list:

   ```sh
   chezmoi edit ~/.pixi/manifests/pixi-global.toml
   ```

   This edits the template in the repository,
   [`dot_pixi/manifests/pixi-global.toml.tmpl`](dot_pixi/manifests/pixi-global.toml.tmpl).

3. Add an environment for it. `exposed` maps each command to put on the
   PATH to the command in the package:

   ```toml
   [envs.fd-find]
   channels = ["conda-forge"]
   dependencies = { fd-find = "*" }
   exposed = { fd = "fd" }
   ```

   Every exposed command must exist in the package on every platform that
   gets it, otherwise `pixi global sync` fails. To see what a package
   provides, install it once with `pixi global install <package>`: it
   prints the commands it exposes, and adds a ready-made entry to
   `~/.pixi/manifests/pixi-global.toml` to copy from.

4. For a single platform, wrap the entry in a template condition, like
   the uutils entry for Windows:

   ```toml
   {{- if eq .chezmoi.os "windows" }}
   [envs.uutils-coreutils]
   …
   {{- end }}
   ```

   `.chezmoi.os` is `linux`, `darwin` or `windows`.

5. Run `chezmoi apply`. It notices the list changed and runs
   `pixi global sync`.

6. Commit and push. Other machines get it with `chezmoi update`.

To remove a tool, delete its entry and run `chezmoi apply`.

Do not use `pixi global install`. The next
`chezmoi apply` restores the list from the repository, which removes them.

### Apps and other packages

| What | Where |
|---|---|
| Flathub apps (Fedora Atomic) | [`flatpaks.txt`](flatpaks.txt). Install one with `flatpak --user install flathub <app>`, then `sh sync-packages.sh` updates the list |
| Flathub extensions (Fedora Atomic) | `fedora.flatpak_extensions` in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml), since `sync-packages.sh` only lists apps |
| Layered packages (Fedora Atomic) | `fedora.layered` in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml). Only for what the COSMIC image does not ship yet: setup reminds you to remove one once Fedora includes it |
| winget packages (Windows) | `windows.winget` in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml) |
| Rust components, `cargo install` tools | `rust` in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml) |
| Libraries and tools for compiling Rust | [`dot_local/share/rust-env/pixi.toml`](dot_local/share/rust-env/pixi.toml) |

`chezmoi apply` installs changes to any of these.

## Rust

Everything needed to compile Rust is in one pixi workspace,
`~/.local/share/rust-env`:

- nightly Rust, installed with rustup, including toolchains that projects
  pin in `rust-toolchain.toml`
- cargo's [config](dot_local/share/rust-env/cargo/config.toml), its
  downloads, and tools installed with `cargo install`
- sccache, and its cache
- on Linux, the C compiler, linker and libraries (like OpenSSL) that
  crates with C code need

Nothing outside that directory is changed: `cargo` does not exist outside
the environment. Enter it to compile:

```sh
rust    # alias for: pixi shell --manifest-path ~/.local/share/rust-env/pixi.toml
cargo build
```

Zed does not need it entered: `~/.local/bin/rust-analyzer` runs
rust-analyzer from the environment.

To remove Rust, set `rust.enabled = false` in
[`.chezmoidata/packages.toml`](.chezmoidata/packages.toml) and delete
`~/.local/share/rust-env`.

Projects that pin a toolchain need the cranelift component added to it,
since the cargo config uses cranelift for debug builds. Inside the
project, in the environment:
`rustup component add rustc-codegen-cranelift-preview`

## Virtual machines

On Fedora Atomic, [virt-manager](https://virt-manager.org) from Flathub runs
Linux and Windows virtual machines, with the QEMU extension from Flathub.
Nothing is installed on the system: the virtual machines run as your user
(the "QEMU/KVM User session" connection in virt-manager), and are as fast
as usual thanks to KVM.

- **Windows 11** needs UEFI firmware and a TPM. When creating the virtual
  machine, choose "Customize configuration before install", then set the
  firmware to UEFI and add a TPM device (emulated, TPM 2.0). From the
  command line:

  ```sh
  flatpak run --command=virt-install org.virt_manager.virt-manager \
      --connect qemu:///session --name win11 --osinfo win11 \
      --memory 8192 --vcpus 4 --boot uefi \
      --tpm model=tpm-crb,backend.type=emulator,backend.version=2.0 \
      --disk size=80 --cdrom ~/Downloads/Win11.iso --network user
  ```

- **Networking** is NAT only: virtual machines reach the internet, but the
  host cannot reach them by IP address, and there is no bridged networking.
- **Disks** are in `~/.var/app/org.virt_manager.virt-manager/data/images`.
  virt-manager can open ISOs in `~/Downloads` and the other home folders.
- `virsh` works with
  `flatpak run --command=virsh org.virt_manager.virt-manager --connect qemu:///session`.

## Everyday use

```sh
chezmoi edit ~/.config/nushell/config.nu  # edit a config file
chezmoi apply                             # apply changes from the repository
chezmoi update                            # pull from GitHub, then apply
chezmoi add ~/.config/some/file           # start managing a new file
chezmoi diff                              # what `chezmoi apply` would change
chezmoi cd                                # open nushell in the repository
```

## Platform details

**Config locations.** The config files live in `~/.config` on every
platform. Some apps read theirs elsewhere on macOS (`~/Library/Application
Support`) and Windows (`AppData`), so those locations are linked to
`~/.config`, and the app finds its config there:

- On macOS with symlinks, like on Linux.
- On Windows with junctions. A junction is Windows' kind of link for
  folders: `AppData\Roaming\Zed` is then another name for `~\.config\zed`,
  and programs see the same files through both paths. Unlike symlinks,
  creating junctions does not need administrator rights. Deleting a
  junction only removes the link, not the files.

**Zed on Fedora Atomic** is a flatpak, so it runs in a sandbox. Its
terminal runs nushell outside the sandbox through
[host-spawn](https://github.com/1player/host-spawn), and rust-analyzer and
the pixi tools run inside it. See
[`dot_local/share/flatpak/overrides/`](dot_local/share/flatpak/overrides).
`zed` opens it from a terminal on every platform.

**Automatic login on Fedora Atomic.** The disk encryption password at boot
is the only password: COSMIC then logs in by itself. Set `login.autologin`
in [`.chezmoidata/desktop.toml`](.chezmoidata/desktop.toml) to turn it off
(`chezmoi apply` asks for the sudo password to change it).

The keyring, where apps like Zed and git keep passwords, normally unlocks
with the login password. With automatic login there is none, so it
unlocks with a random password instead, which systemd stores encrypted so
that only this machine can read it. The keyring stays encrypted on disk,
and nothing ever asks for its password. This needs a keyring created by
these dotfiles: setup explains what to do if one already exists.

**Layered packages on Fedora Atomic.** One package is layered onto the
system image, because the COSMIC image does not ship it yet: `oo7-portal`,
which lets flatpak apps like Zed and Proton Pass store passwords in the
keyring. Once Fedora adds it to the image, it is no longer needed: setup
then reminds you to remove it from `fedora.layered` and to run
`rpm-ostree uninstall oo7-portal`.

**uutils on Windows** provides `ls`, `cp`, `cat` and the other coreutils.
Windows' own `expand`, `hostname`, `more`, `sort`, `timeout` and `whoami`
come first on the PATH, and in nushell its built-in commands like `ls` come
first, so call those with a caret: `^ls`.

## Troubleshooting

**A setup script failed.** Fix the cause and run `chezmoi apply` again:
scripts that already succeeded are skipped.

**Run all setup scripts again**, for example after deleting an
environment:

```sh
chezmoi state delete-bucket --bucket=entryState
chezmoi apply
```

**A tool is missing** after installing: open a new terminal, so it picks up
the PATH.

## Layout

| Path | Contents |
|---|---|
| `dot_config/` | config files, installed to `~/.config` |
| `dot_pixi/manifests/` | global CLI tools, for pixi |
| `dot_local/share/rust-env/` | the Rust workspace, including cargo's config |
| `dot_local/bin/` | `zed` on Linux, and `rust-analyzer` from the Rust workspace |
| `.chezmoidata/packages.toml` | packages pixi does not provide |
| `.chezmoidata/desktop.toml` | desktop settings, like automatic login |
| `.chezmoiscripts/` | setup scripts |
| `.chezmoitemplates/` | pieces shared by templates and scripts |
| `.chezmoiexternal.toml.tmpl` | downloaded files: fonts, and `host-spawn` |
| `.chezmoiignore` | which files each platform gets |
| `Library/` | macOS: links app config locations to `~/.config` |
| `dot_local/share/zed-flatpak/`, `dot_local/share/flatpak/`, `dot_var/` | Fedora Atomic: Zed flatpak integration |
| `flatpaks.txt`, `sync-packages.sh` | Flathub apps, and a script to update the list |
