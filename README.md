# dotfiles

My config for Fedora Atomic (COSMIC), macOS and Windows, managed with
[chezmoi](https://chezmoi.io). CLI tools come from [pixi](https://pixi.sh)
on every platform.

## Install

On a fresh machine, run one command. It installs all packages and puts the
config files in place.

**Fedora Atomic, macOS**

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /tmp init --apply --use-builtin-git=true nik-rev
```

**Windows** (PowerShell)

```powershell
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b '$env:TEMP' init --apply nik-rev"
```

Windows may show UAC prompts.

<details>
<summary>What the command does</summary>

It downloads chezmoi to a temporary directory, clones this repository to
`~/.local/share/chezmoi` and runs `chezmoi apply`. That runs the setup
scripts, which also install chezmoi itself with pixi.

`--use-builtin-git` lets chezmoi clone before git is installed. macOS has a
placeholder `git` that only offers to install the developer tools.

</details>

## What gets installed

| | Fedora Atomic | macOS | Windows |
|---|---|---|---|
| CLI tools | pixi | pixi | pixi |
| Apps | Flathub | Zed installer | winget |
| Rust (nightly) | rust-env | rust-env + Xcode Command Line Tools | rust-env + VS C++ build tools |

Nothing is layered with `rpm-ostree` on Fedora Atomic, and no toolbox is
needed. On other Linux distributions, only the config files are installed.

## Everyday use

```sh
chezmoi edit ~/.config/nushell/config.nu  # edit a config file
chezmoi apply                             # apply changes from the repository
chezmoi update                            # pull from GitHub, then apply
chezmoi add ~/.config/some/file           # start managing a new file
chezmoi cd                                # open a shell in the repository
```

### Packages

CLI tools are listed in pixi's own format in
[`dot_pixi/manifests/pixi-global.toml.tmpl`](dot_pixi/manifests/pixi-global.toml.tmpl).
Add one there, not with `pixi global install`, then run `chezmoi apply`:

```sh
chezmoi edit ~/.pixi/manifests/pixi-global.toml
```

Find package names with `pixi search <name>`, or on
[prefix.dev](https://prefix.dev/channels/conda-forge).

Everything pixi does not provide, like Windows apps and Rust components, is
in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml). Flathub apps
on Fedora Atomic are listed in `flatpaks.txt`. After installing one with
`flatpak --user install flathub <app>`, run `sh sync-packages.sh`.

### Rust

Rust lives in its own pixi environment, `~/.local/share/rust-env`, with
everything needed to compile it: nightly Rust (rustup), cargo's config and
downloads, sccache, and on Linux the C compiler and libraries that `-sys`
crates need. Nothing outside that directory is changed, and `cargo` only
exists inside the environment. Enter it to compile:

```sh
rust    # nushell. Elsewhere: pixi shell --manifest-path ~/.local/share/rust-env/pixi.toml
```

Zed does not need it entered: `~/.local/bin/rust-analyzer` runs
rust-analyzer from the environment.

To remove Rust, set `rust.enabled = false` in `.chezmoidata/packages.toml`
and delete `~/.local/share/rust-env`. `pixi clean cache` also removes the
packages pixi downloaded.

Projects that pin a toolchain in `rust-toolchain.toml` need the cranelift
component added to it, since the cargo config uses cranelift for debug
builds: `rustup component add rustc-codegen-cranelift-preview`

### Re-running the setup

The setup scripts only run when they, or the package lists, change. To run
them anyway:

```sh
chezmoi state delete-bucket --bucket=entryState
chezmoi apply
```

## Layout

| Path | Contents |
|---|---|
| `dot_config/` | config files, installed to `~/.config` |
| `dot_pixi/manifests/` | CLI tools for every platform, installed with pixi |
| `dot_local/share/rust-env/` | the Rust environment, including cargo's config |
| `.chezmoidata/packages.toml` | packages pixi does not provide |
| `.chezmoiscripts/` | setup scripts, one set per platform |
| `.chezmoitemplates/` | pieces shared by the scripts |
| `.chezmoiexternal.toml.tmpl` | files chezmoi downloads: fonts, and `host-spawn` for the Zed flatpak |
| `dot_local/bin/` | `zed` on Linux, whatever Zed's own command is called, and `rust-analyzer` from the Rust environment |
| `Library/` | macOS: links app config locations to `~/.config` |
| `dot_local/share/zed-flatpak/`, `dot_var/` | Fedora Atomic: Zed flatpak integration |
| `.chezmoiignore` | which files each platform gets |

On Windows, a setup script links the `AppData` config locations to
`~/.config` instead.
