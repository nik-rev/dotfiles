---
# This repository contains my personal config files.
#
# They are set up by this script: README.rs

package.edition = "2024"

[dependencies]
etcetera = "0.11"
eyre = "0.6"
rayon = "1.12"
walkdir = "2.5"
fs = { package = "fs-err", version = "3" }
---
#![feature(decl_macro)]
#![feature(super_let)]

use etcetera::BaseStrategy as _;
use eyre::OptionExt as _;
use rayon::prelude::*;
use std::path::PathBuf;

fn main() -> Result {
    let script_dir = {
        let script_path = std::env::args().next().expect("script path");
        super let script_path = PathBuf::from(script_path);

        script_path.parent().ok_or_eyre("no parent")?
    };

    let strategy = etcetera::choose_base_strategy()?;
    let config = strategy.config_dir();
    let home = std::env::home_dir().ok_or_eyre("no home dir")?;

    let map = paths! {
        "alacritty.toml" => config.join("alacritty/alacritty.toml"),
        "cargo.config.toml" => home.join(".cargo/config.toml"),
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
    };

    map.par_iter().for_each(|(src, dest)| {
        let src = script_dir.join(src);

        for file in walkdir::WalkDir::new(&src)
            .into_iter()
            .flatten()
            .filter(|entry| entry.file_type().is_file())
        {
            let relative_path = file.path().strip_prefix(&script_dir).unwrap();
            let new_path = if src.is_dir() {
                let dir = relative_path.components().next().unwrap();
                let relative_path = relative_path.strip_prefix(dir).unwrap();
                dest.join(relative_path)
            } else {
                dest.join(relative_path)
            };
            let old_path = relative_path;

            // We're writing to a file, let's create a directory there
            if let Some(parent) = new_path.parent() && matches!(fs::exists(&parent), Ok(false)) {
                fs::create_dir_all(&parent).unwrap();
            }

            let contents = fs::read_to_string(&old_path).unwrap();

            fs::remove_file(&new_path).unwrap();
            fs::write(&new_path, &contents).unwrap();
        }
    });

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
