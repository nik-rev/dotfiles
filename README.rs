#!/bin/env -S cargo +nightly -Zscript
---
# This repository contains my personal config files.
#
# They are set up by this script: README.rs, which is both the
# markdown file you are reading right now, but also an executable script!

package.edition = "2024"

[dependencies]
etcetera = "0.11"
eyre = "0.6"
rayon = "1.12"
walkdir = "2.5"
fs = { package = "fs-err", version = "3" }
which = "8.0"
---
#![feature(const_trait_impl)]
#![feature(const_convert)]
#![feature(decl_macro)]
#![feature(super_let)]

use etcetera::BaseStrategy as _;
use eyre::OptionExt as _;
use rayon::prelude::*;
use std::path::PathBuf;
use std::process::Command;

const INSTALL_PACKAGES: bool = option_env!("SETUP").is_some() || option_env!("INSTALL_PACKAGES").is_some();

fn main() -> Result {
    let script_dir = {
        let script_path = std::env::args().next().expect("script path");
        super let script_path = PathBuf::from(script_path);

        script_path.parent().ok_or_eyre("no parent")?
    };

    let strategy = etcetera::choose_base_strategy()?;
    let config = strategy.config_dir();
    let home = std::env::home_dir().ok_or_eyre("no home dir")?;

    #[rustfmt::skip]
    const ENSURE_INSTALLED: &[Package] = ensure_installed![
        "sccache",
        linux("zed-preview-bin"), win("zed-nightly"), mac("zed@preview"),
        "mpv",
        "fish",
        "hyperfine",
        "vim",
        "delta",
        "ripgrep",
        unix("nushell"), win("nu"),
        "zoxide",
        "carapace-bin",

        cargo("cargo-outdated"),
        cargo("cargo-expand"),
        cargo("cargo-reedme"),
        cargo("live-server"),
        cargo("cargo-nextest"),

        win("coreutils"),

        linux("kanshi"), // dynamic display configuration Wayland daemon
        linux("noto-fonts-cjk"),
        linux("noto-fonts-emoji"),
        linux("noto-fonts"),
        linux("ttf-jetbrains-mono"),
        linux("ttf-jetbrains-mono-nerd"),
    ];

    // scoop buckets: main

    let paths = paths! {
        "alacritty.toml" => config.join("alacritty/alacritty.toml"),
        "cargo.config.toml" => home.join(".cargo/config.toml"),
        "cargo.config.toml" => home.join("random/.cargo/config.toml"),
        "git.config" => config.join("git/config"),
        "git.attributes" => config.join("git/attributes"),
        "atuin.toml" => config.join("atuin/config.toml"),
        "atuin.theme.toml" => config.join("atuin/themes/catppuccin.toml"),
        "gitui.theme.ron" => config.join("gitui/theme.ron"),
        "glazewm.yaml" => home.join(".glzr/glazewm/config.yaml"),
        "kitty.conf" => config.join("kitty/kitty.conf"),
        "lazygit.yml" => config.join("lazygit/config.yml"),
        "rio.toml" => config.join("rio/config.toml"),
        "sway.config" => config.join("sway/config"),
        "wezterm.lua" => config.join("wezterm/wezterm.lua"),
        "yazi.toml" => config.join("yazi/yazi.toml"),
        "yazi.theme.toml" => config.join("yazi/yazi.theme.toml"),
        "zed.settings.jsonc" => config.join(format!("{ZED}/settings.json")),
        "zed.keymap.jsonc" => config.join(format!("{ZED}/keymap.json")),
        "glide.ts" => config.join("glide/glide.ts"),
        "bat" => config.join("bat"),
        "nushell" => config.join("nushell"),
        "presenterm" => config.join("presenterm"),
        "helix" => config.join("helix"),
        "bottom.toml" => config.join("bottom/bottom.toml"),
        "niri.config.kdl" => config.join("niri/config.kdl"),
        "kanshi.config" => config.join("kanshi/config"),
    };

    paths
        .par_iter()
        .map(|(src, dest)| {
            let src = script_dir.join(src);

            for file in walkdir::WalkDir::new(&src)
                .into_iter()
                .flatten()
                .filter(|entry| entry.file_type().is_file())
            {
                let relative_path = file.path().strip_prefix(&script_dir)?;

                let new_path = if src.is_dir() {
                    let dir = relative_path
                        .components()
                        .next()
                        .ok_or_eyre("no component")?;
                    let relative_path = relative_path.strip_prefix(dir)?;
                    dest.join(relative_path)
                } else {
                    dest.to_path_buf()
                };
                let old_path = relative_path;

                // We're writing to a file, let's create a directory there
                if let Some(parent) = new_path.parent()
                    && !fs::exists(&parent)?
                {
                    fs::create_dir_all(&parent)?;
                }

                let contents = fs::read_to_string(&old_path)?;

                // Clean up.
                if fs::exists(&new_path)? {
                    let metadata = fs::metadata(&new_path)?;

                    if metadata.is_dir() {
                        fs::remove_dir_all(&new_path)?;
                    } else if metadata.is_file() {
                        fs::remove_file(&new_path)?;
                    } else {
                        panic!();
                    }
                }

                fs::write(&new_path, &contents)?;
            }

            eyre::Ok(())
        })
        .for_each(|result| match result {
            Ok(()) => {}
            Err(err) => println!("{err}"),
        });

    if !INSTALL_PACKAGES {
        return Ok(());
    }

    for pkg in ENSURE_INSTALLED {
        if pkg.linux && cfg!(target_os = "linux") {
            install_pkg(System::Linux, pkg.manager, pkg.name)?;
        }
        if pkg.win && cfg!(target_os = "windows") {
            install_pkg(System::Windows, pkg.manager, pkg.name)?;
        }
        if pkg.mac && cfg!(target_os = "macos") {
            install_pkg(System::Mac, pkg.manager, pkg.name)?;
        }
    }

    Ok(())
}

#[derive(Copy, Clone)]
enum System {
    Linux,
    Windows,
    Mac,
}

fn install_pkg(system: System, manager: PackageManager, package: &'static str) -> Result {
    match manager {
        PackageManager::System => match system {
            System::Linux => {
                Command::new("paru")
                    .arg("-S")
                    .arg("--noconfirm")
                    .arg(package)
                    .status()?;
            }
            System::Windows => {
                Command::new("choco")
                    .arg("install")
                    .arg("-y")
                    .arg(package)
                    .status()?;
            }
            System::Mac => {
                Command::new("brew").arg("install").arg(package).status()?;
            }
        },
        PackageManager::Cargo => {
            let _ = system;

            Command::new("cargo").arg("install").arg(package).status()?;
        }
    }

    Ok(())
}

macro paths($($src:expr => $dest:expr),* $(,)?) {
    [$(($src, $dest)),*]
}

const ZED: &str = cfg_select! {
    target_os = "windows" => { "Zed" },
    _ => { "zed" },
};

type Result<T = (), E = eyre::Report> = eyre::Result<T, E>;

macro ensure_installed($($expr:expr),* $(,)?) {
    &[$(Package::from($expr)),*]
}

#[derive(Debug, Clone, Copy)]
enum PackageManager {
    System,
    Cargo,
}

#[derive(Debug, Clone, Copy)]
struct Package {
    name: &'static str,
    linux: bool,
    mac: bool,
    win: bool,
    manager: PackageManager,
}

const fn linux(pkg: impl [const] Into<Package>) -> Package {
    Package {
        linux: true,
        manager: PackageManager::System,
        ..pkg.into()
    }
}

const fn win(pkg: impl [const] Into<Package>) -> Package {
    Package {
        win: true,
        manager: PackageManager::System,
        ..pkg.into()
    }
}

const fn mac(pkg: impl [const] Into<Package>) -> Package {
    Package {
        mac: true,
        manager: PackageManager::System,
        ..pkg.into()
    }
}

const fn unix(pkg: impl [const] Into<Package>) -> Package {
    Package {
        mac: true,
        linux: true,
        manager: PackageManager::System,
        ..pkg.into()
    }
}

const fn cargo(pkg: impl [const] Into<Package>) -> Package {
    Package {
        manager: PackageManager::Cargo,
        ..pkg.into()
    }
}

impl const From<&'static str> for Package {
    fn from(pkg: &'static str) -> Package {
        Package {
            name: pkg,
            linux: true,
            mac: true,
            win: true,
            manager: PackageManager::System,
        }
    }
}
