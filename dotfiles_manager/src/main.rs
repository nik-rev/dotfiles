use simply_colored::*;
use std::env::current_dir;
use std::fs::canonicalize;
use std::io::Write as _;
use std::{env, fs, path::Path};

use log::Level;
use walkdir::WalkDir;

fn main() {
    env_logger::Builder::new()
        .filter_level(log::LevelFilter::Info)
        .format(|buf, record| {
            let color = match record.level() {
                Level::Error => RED,
                Level::Warn => YELLOW,
                Level::Info => GREEN,
                Level::Debug => BLUE,
                Level::Trace => CYAN,
            };
            let level = record.level();
            let message = record.args();

            writeln!(buf, "{BLACK}[{color}{level}{BLACK}]{RESET} {message}",)
        })
        .init();

    let home = env::home_dir().unwrap();

    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("..");
    let root_configs = root.join("configs");
    let current_dir = current_dir().unwrap();

    #[cfg(target_os = "windows")]
    let config = home.join("AppData");
    #[cfg(not(target_os = "windows"))]
    let config = home.join(".config");

    WalkDir::new(&root_configs)
        .into_iter()
        .flatten()
        .filter(|dir_entry| dir_entry.file_type().is_file())
        .for_each(|file| {
            let old_location = canonicalize(file.path()).unwrap();
            let relative_location = old_location.strip_prefix(&root_configs).unwrap();
            let new_location = canonicalize(config.join(relative_location)).unwrap();
            let old_relative_to_cwd = old_location.strip_prefix(&current_dir).unwrap().display();

            // 1. Remove the old file
            match fs::remove_file(&old_location) {
                Err(err) if err.kind() == std::io::ErrorKind::NotFound => (),
                Err(err) => {
                    panic!("{err}");
                }
                Ok(()) => {
                    log::info!("{RED}removed{RESET} {old_relative_to_cwd}");
                }
            }

            // 2. Parent directory of existing file might not exit
            //
            //    We don't want to symlink directories themselves,
            //    because they might contain data we don't want in
            //    our dotfiles.
            fs::create_dir_all(new_location.parent().unwrap()).unwrap();

            // 3. Symlink old -> new
            #[cfg(target_os = "windows")]
            std::os::windows::fs::symlink_file(&old_location, &new_location).unwrap();
            #[cfg(not(target_os = "windows"))]
            std::os::unix::fs::symlink(&old_location, &new_location).unwrap();

            log::info!(
                "{CYAN}symlinked{RESET} {} {BLACK}->{RESET} ~{}{}",
                old_relative_to_cwd,
                std::path::MAIN_SEPARATOR,
                new_location.strip_prefix(&home).unwrap().display()
            );
        })
}
