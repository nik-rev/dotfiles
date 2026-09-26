# dotfiles

My config for Fedora Atomic (COSMIC), macOS and Windows, managed with
[chezmoi](https://chezmoi.io).

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

Homebrew asks for your password once, and Windows may show UAC prompts.

<details>
<summary>What the command does</summary>

It downloads chezmoi to a temporary directory, clones this repository to
`~/.local/share/chezmoi` and runs `chezmoi apply`. That runs the setup
scripts, which also install chezmoi itself with Homebrew or winget.

`--use-builtin-git` lets chezmoi clone before git is installed. macOS has a
placeholder `git` that only offers to install the developer tools.

</details>

## What gets installed

| | CLI tools | Apps | Rust (nightly) |
|---|---|---|---|
| Fedora Atomic | Homebrew | Flathub | in the `main` toolbox |
| macOS | Homebrew | Homebrew | rustup |
| Windows | winget | winget | rustup + VS C++ build tools |

Nothing is layered with `rpm-ostree` on Fedora Atomic.

## Everyday use

```sh
chezmoi edit ~/.config/nushell/config.nu  # edit a config file
chezmoi apply                             # apply changes from the repository
chezmoi update                            # pull from GitHub, then apply
chezmoi add ~/.config/some/file           # start managing a new file
chezmoi cd                                # open a shell in the repository
```

### Packages

Every package is listed in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml),
with its Homebrew and winget name. Edit it and run `chezmoi apply`. The setup
scripts re-run whenever the list changes.

Flathub apps on Fedora Atomic are listed in `flatpaks.txt`. After installing
one with `flatpak --user install flathub <app>`, run `sh sync-packages.sh` to
update the list.

### Rust on Fedora Atomic

Fedora Atomic has no C toolchain, which Rust needs for linking, so Rust
lives in a toolbox:

```sh
toolbox enter main
```

Everything else runs on the host. Zed's `cargo` and `rust-analyzer` run in
the toolbox automatically, through the wrappers in
`~/.local/share/zed-flatpak/bin`.

### Re-running the setup

The setup scripts only run when they, or the package lists, change. To run
them anyway, for example after deleting the toolbox:

```sh
chezmoi state delete-bucket --bucket=entryState
chezmoi apply
```

## Layout

| Path | Contents |
|---|---|
| `dot_config/`, `dot_cargo/` | config files, installed to `~/.config` and `~/.cargo` |
| `.chezmoidata/packages.toml` | packages for every platform |
| `.chezmoiscripts/` | setup scripts, one set per platform |
| `.chezmoitemplates/` | pieces shared by the scripts |
| `Library/` | macOS: links app config locations to `~/.config` |
| `dot_local/share/zed-flatpak/`, `dot_var/` | Fedora Atomic: lets the Zed flatpak use the host and toolbox |
| `.chezmoiignore` | which files each platform gets |

On Windows, a setup script links the `AppData` config locations to
`~/.config` instead.
