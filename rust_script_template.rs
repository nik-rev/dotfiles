#!/bin/env -S cargo +nightly -Zscript
---
package.edition = "2024"

[dependencies]
farben = { version = "0.17", features = ["markdown"] }
color-eyre = "0.6"
fs = { version = "3.3", package = "fs-err" }
camino = "1.2"
---

fn main() -> Result {
    color_eyre::install()?;

    Ok(())
}

type Result<T = (), E = eyre::Report> = eyre::Result<T, E>;
