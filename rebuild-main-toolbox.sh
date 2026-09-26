#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# Configuration
# -------------------------------

container_name="main"

REPOSITORIES=(
    "https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo"
)

PACKAGES=(
    vim
    chezmoi
    nushell
    rust
    lazygit
    fish
    cargo
    typst
    flatpak
)

# -------------------------------
# Validation
# -------------------------------

if ! command -v toolbox >/dev/null 2>&1; then
    printf '%s\n' 'error: toolbox is not installed' >&2
    exit 1
fi

if [[ -f /run/.containerenv ]]; then
    printf '%s\n' \
        'error: run this script from the host, not inside a Toolbox/container' >&2
    exit 1
fi

if ((${#PACKAGES[@]} == 0)); then
    printf '%s\n' 'error: PACKAGES is empty' >&2
    exit 1
fi

# -------------------------------
# Create or reuse Toolbox
# -------------------------------

if ! toolbox run --container "$container_name" true >/dev/null 2>&1; then
    printf 'Creating Toolbox %q...\n' "$container_name"
    toolbox create "$container_name"
else
    printf 'Using existing Toolbox %q...\n' "$container_name"
fi

# -------------------------------
# Synchronize repositories
# -------------------------------

for index in "${!REPOSITORIES[@]}"; do
    repository_url="${REPOSITORIES[$index]}"
    repository_file="/etc/yum.repos.d/external-${index}.repo"

    printf 'Checking repository definition: %s\n' "$repository_url"

    toolbox run --container "$container_name" \
        sh -c '
            set -eu

            repository_url="$1"
            repository_file="$2"
            temporary_file="$(mktemp)"

            cleanup() {
                rm -f "$temporary_file"
            }

            trap cleanup EXIT

            curl -fsSL "$repository_url" -o "$temporary_file"

            if sudo test -f "$repository_file" &&
               sudo cmp -s "$temporary_file" "$repository_file"; then
                printf "Repository definition is unchanged.\n"
            else
                sudo install -D -m 0644 \
                    "$temporary_file" \
                    "$repository_file"

                printf "Repository definition updated.\n"
            fi
        ' _ "$repository_url" "$repository_file"
done

# -------------------------------
# Find missing packages
# -------------------------------

mapfile -t installed < <(
    toolbox run --container "$container_name" \
        rpm -qa --qf '%{NAME}\n' |
        LC_ALL=C sort -u
)

missing=()

for package in "${PACKAGES[@]}"; do
    if ! printf '%s\n' "${installed[@]}" | grep -Fxq "$package"; then
        missing+=("$package")
    fi
done

# -------------------------------
# Install missing packages
# -------------------------------

if ((${#missing[@]})); then
    printf 'Installing %s missing package(s)...\n' "${#missing[@]}"

    toolbox run --container "$container_name" \
        sudo dnf install -y "${missing[@]}"
else
    printf 'All configured packages are already installed.\n'
fi

printf 'Toolbox %q synchronized successfully.\n' "$container_name"
