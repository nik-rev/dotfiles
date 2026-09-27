# Installs nightly Rust into the rust-env pixi environment, with the
# components in rust.components and, on Linux, the tools in
# rust.cargo_linux from .chezmoidata/packages.toml.
#
# Runs inside the environment, so RUSTUP_HOME and CARGO_HOME point into it
set -eu

if [ ! -x "$CARGO_HOME/bin/rustup" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
        sh -s -- -y --no-modify-path --default-toolchain nightly --profile default
fi

rustup default nightly
rustup component add{{ range .rust.components }} {{ . | quote }}{{ end }}
{{- if eq .chezmoi.os "linux" }}

cargo_home="$CARGO_HOME"
temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

# Own CARGO_HOME for the build, so the cargo config is not used: it links
# with wild, which is one of the packages installed here. Link with clang
# from the environment instead
CARGO_HOME="$temporary_dir" RUSTFLAGS="-C linker=clang" \
    cargo install --locked --root "$cargo_home"
{{- range .rust.cargo_linux }} {{ . | quote }}{{ end }}
{{- end }}
