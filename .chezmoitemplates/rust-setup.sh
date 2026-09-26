# Installs nightly Rust with rustup, and the tools in rust.cargo from
# .chezmoidata/packages.toml. Used on macOS and in the Fedora Atomic toolbox
set -eu

export PATH="$HOME/.cargo/bin:$PATH"

if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
        sh -s -- -y --no-modify-path --default-toolchain nightly --profile default
fi

rustup default nightly
rustup component add{{ range .rust.components }} {{ . | quote }}{{ end }}

temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

# Own CARGO_HOME so ~/.cargo/config.toml is not used: it needs sccache and,
# on Linux, links with wild, which is one of the packages installed here
CARGO_HOME="$temporary_dir" cargo install --locked --root "$HOME/.cargo"
{{- range .rust.cargo }} {{ . | quote }}{{ end }}
{{- if eq .chezmoi.os "linux" }}{{ range .rust.cargo_linux }} {{ . | quote }}{{ end }}{{ end }}
