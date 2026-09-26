#!/usr/bin/env bash
set -euo pipefail

# Install packages listed beside this script, regardless of the current
# working directory.
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
flatpaks_file="$script_dir/flatpaks.txt"
rpms_file="$script_dir/rpms.txt"

if ! command -v flatpak >/dev/null 2>&1; then
    printf '%s\n' "error: flatpak is not installed" >&2
    exit 1
fi

flatpak --user remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

if [[ -f "$flatpaks_file" ]]; then
    while IFS= read -r app; do
        [[ -z "$app" || "$app" == \#* ]] && continue
        flatpak --user install --noninteractive -y flathub "$app"
    done <"$flatpaks_file"
fi

if [[ -f "$rpms_file" ]]; then
    rpm_packages=()
    while IFS= read -r package; do
        [[ -z "$package" || "$package" == \#* ]] && continue
        rpm_packages+=("$package")
    done <"$rpms_file"

    if ((${#rpm_packages[@]})); then
        sudo rpm-ostree install --idempotent --allow-inactive \
            "${rpm_packages[@]}"
        printf '%s\n' "Host RPM changes are staged; reboot to activate them."
    fi
fi
