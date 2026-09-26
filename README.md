# dotfiles

Managed with [chezmoi](https://chezmoi.io). Works on Fedora Atomic (COSMIC),
macOS and Windows.

## Set up a new machine

Fedora Atomic and macOS:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply --use-builtin-git=true nik-rev
```

Windows (PowerShell):

```powershell
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b '$HOME\.local\bin' init --apply nik-rev"
```

This clones the repository, installs everything and puts the config files in
place. Installing Homebrew asks for your password once.

What gets installed:

- **Fedora Atomic**: graphical apps from Flathub (`flatpaks.txt`), CLI tools
  from Homebrew, and a toolbox named `main` with nightly Rust for compiling.
  Nothing is layered with `rpm-ostree`.
- **macOS**: CLI tools and Zed from Homebrew, and nightly Rust.
- **Windows**: CLI tools and Zed from winget, the Visual Studio C++ build
  tools, and nightly Rust.

## Packages

All packages are listed in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml).
After changing it, run `chezmoi apply` to install the new packages.

Graphical applications on Fedora Atomic are listed in `flatpaks.txt`. Install
one with `flatpak --user install flathub <application>`, then update the list
with `sh sync-packages.sh`.

## Compiling Rust on Fedora Atomic

The Rust toolchain only lives in the toolbox, which has the C toolchain that
linking needs:

```sh
toolbox enter main
```

Zed's `cargo` and `rust-analyzer` already run inside it automatically.

## Re-running the setup scripts

The scripts in `.chezmoiscripts` only run again when they, or the package
lists they use, change. To run them all again, for example after deleting the
toolbox:

```sh
chezmoi state delete-bucket --bucket=entryState
chezmoi apply
```
