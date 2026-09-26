#!/usr/bin/env bash
set -euo pipefail

# Write both package lists next to this script, regardless of the current
# working directory.
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
flatpaks_file="$script_dir/flatpaks.txt"
flatpaks_tmp="$(mktemp "${flatpaks_file}.tmp.XXXXXX")"
trap 'rm -f "$flatpaks_tmp"' EXIT

if ! command -v flatpak >/dev/null 2>&1; then
    printf '%s\n' 'error: flatpak is not installed' >&2
    exit 1
fi

# Include applications installed from the Flathub remote, whether they are
# installed per-user or system-wide. Keep one application ID per line.
flatpak list --app --columns=application,origin |
    awk -F '\t' '$2 == "flathub" { print $1 }' |
    LC_ALL=C sort -u >"$flatpaks_tmp"

# Replace the lists only after both commands succeed, so a failed query does
# not erase an existing list. This also creates the files if absent.
mv "$flatpaks_tmp" "$flatpaks_file"
trap - EXIT

printf 'Wrote %s (%s applications)\n' "$flatpaks_file" "$(wc -l <"$flatpaks_file")"
