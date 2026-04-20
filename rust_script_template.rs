#!/bin/env -S cargo +nightly -Zscript
---
package.description = """
Template for Rust scripts
"""
package.edition = "2024"

[dependencies]
farben = "0.17"
eyre = "0.6"
color-eyre = "0.6"
fs = { version = "3.3", package = "fs-err" }
camino = "1.2"
log = "0.4"
colog = "1.4"
---

#[allow(unused)]
use prelude::*;

fn main() -> Result {
    color_eyre::install()?;
    colog::init();

    Ok(())
}

#[allow(unused)]
mod prelude {
    pub use crate::eyre_prelude::*;
    pub use camino::Utf8Path as Path;
    pub use camino::Utf8PathBuf as PathBuf;
    pub use farben::prelude::*;
    pub use log::debug;
    pub use log::error;
    pub use log::info;
    pub use log::trace;
    pub use log::warn;
}

#[allow(unused)]
mod eyre_prelude {
    pub type Result<T = (), E = eyre::Report> = eyre::Result<T, E>;

    pub use eyre::bail;
    pub use eyre::ensure;
    pub use eyre::eyre as report;
    pub use eyre::Report;
    pub use eyre::WrapErr as ResultExt;

    use core::fmt::Debug;
    use core::fmt::Display;

    pub trait OptionExt<T> {
        fn try_ok(self) -> Result<T>;

        fn ok_or_report<M>(self, message: M) -> Result<T>
        where
            M: Debug + Display + Send + Sync + 'static;
    }

    impl<T> OptionExt<T> for Option<T> {
        #[track_caller]
        fn try_ok(self) -> Result<T> {
            eyre::OptionExt::ok_or_eyre(self, "called `try_ok` on a `None` value")
        }

        #[track_caller]
        fn ok_or_report<M>(self, message: M) -> Result<T>
        where
            M: Debug + Display + Send + Sync + 'static,
        {
            eyre::OptionExt::ok_or_eyre(self, message)
        }
    }
}
