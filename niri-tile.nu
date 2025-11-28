#!/usr/bin/env nu

# Border size around each window (excludes gaps)
const BORDER_WIDTH = 2;

let monitor_width = niri msg -j focused-output
    | from json
    | get logical
    | get width
let focused_workspace = niri msg -j workspaces
    | from json
    | where is_focused | first | get id
# excludes floating windows
let windows_in_workspace = niri msg -j windows
    | from json
    | where workspace_id == $focused_workspace
    | where { ($in.layout.pos_in_scrolling_layout | get 1)  == 1 }
let window_count = $windows_in_workspace | length

# account for border on left and right
let new_window_width = $monitor_width / $window_count - $BORDER_WIDTH - $BORDER_WIDTH

for window in $windows_in_workspace {
    niri msg action set-window-width --id $window.id $new_window_width
}
niri msg action focus-column-first
