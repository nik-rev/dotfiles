# Installs nightly Rust into the rust-env pixi environment, along with the
# components from rust.components and, on Linux, the tools from
# rust.cargo_linux (both in .chezmoidata/packages.toml).
#
# This runs inside the environment, so RUSTUP_HOME and CARGO_HOME already
# point into it
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

# The build gets its own CARGO_HOME so that my cargo config isn't used. That
# config links with wild, which is one of the things being installed here,
# so this links with clang from the environment instead
CARGO_HOME="$temporary_dir" RUSTFLAGS="-C linker=clang" \
    cargo install --locked --root "$cargo_home"
{{- range .rust.cargo_linux }} {{ . | quote }}{{ end }}
{{- end }}
