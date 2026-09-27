# Installs nightly Rust with rustup, the components in rust.components from
# .chezmoidata/packages.toml, and on Linux the tools in rust.cargo_linux
set -eu

export PATH="$HOME/.cargo/bin:$HOME/.pixi/bin:$PATH"

if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
        sh -s -- -y --no-modify-path --default-toolchain nightly --profile default
fi

rustup default nightly
rustup component add{{ range .rust.components }} {{ . | quote }}{{ end }}
{{- if eq .chezmoi.os "linux" }}

temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

# Own CARGO_HOME so ~/.cargo/config.toml is not used: it links with wild,
# which is one of the packages installed here. Compile and link with clang
# from pixi, because Fedora Atomic has no C compiler
CARGO_HOME="$temporary_dir" CC=clang CXX=clang++ RUSTFLAGS="-C linker=clang" \
    cargo install --locked --root "$HOME/.cargo"
{{- range .rust.cargo_linux }} {{ . | quote }}{{ end }}
{{- end }}
