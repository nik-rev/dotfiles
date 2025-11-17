source zoxide.nu
source carapace.nu # carapace _carapace nushell o> configs/nushell/carapace.nu
source catppuccin.nu

# Command for switching directories
#
# pass all args to zoxide then list contents of the new directory
def --env --wrapped t [ ...args: string ] {
  z ...$args
  ls+
}

# `nix develop` with nushell
def --wrapped d [ ...args: string ] {
  nix develop ...$args --command nu --execute "$env.PROMPT_INDICATOR = 'n> '"
}

# `nix-shell` with nushell
def --wrapped ns [ ...args: string ] {
  nix-shell ...$args --run `nu --execute "\$env.PROMPT_INDICATOR = 'ns> '"`
}

# for recording videos in a 16 * 9 resolution on a monitor of a different resolution
def spad [] {
  swaymsg gaps left all set 440
  swaymsg gaps right all set 440
}
def unspad [] {
  swaymsg gaps left all set 0
  swaymsg gaps right all set 0
}

$env.path ++= [
    $"($nu.home-path)/.cargo/bin"
]

$env.PROMPT_COMMAND = ""
$env.PROMPT_INDICATOR = { || $"(ansi purple_italic)(if $env.PWD == $nu.home-path { "~" } else { $env.PWD | path split | last } )(ansi reset)$ " }
$env.PROMPT_COMMAND_RIGHT = { || }

$env.config.edit_mode = "vi"

# ctrl-z to toggle foreground and background
$env.config.keybindings ++= [
  {
    name: "unfreeze",
    modifier: control,
    keycode: "char_z",
    event: {
      send: executehostcommand,
      cmd: "job unfreeze"
    },
    mode: emacs
  }
]

# disable welcome screen
$env.config.show_banner = false

$env.cursor_shape.vi_insert = "bar"

# catppuccin compatible colors for ls
$env.LS_COLORS = (vivid generate catppuccin-mocha)

def --env o [] {
  cd ..
  ls+
}

def --env oo [] {
  cd ../..
  ls+
}

def --env ooo [] {
  cd ../../..
  ls+
}

def --env oooo [] {
  cd ../../../..
  ls+
}

def --env ooooo [] {
  cd ../../../../..
  ls+
}

def ls+ [
  --all (-a), # Show hidden files
  --long (-l), # Get all available columns for each entry (slower; columns are platform-dependent)
  --short-names (-s), # Only print the file names, and not the path
  --full-paths (-f), # display paths as absolute paths
  --du (-d), # Display the apparent directory size ("disk usage") in place of the directory metadata size
  --directory (-D), # List the specified directory itself instead of its contents
  --mime-type (-m), # Show mime-type in type column instead of 'file' (based on filenames only; files' contents are not examined)
  --threads (-t), # Use multiple threads to list contents. Output will be non-deterministic.
  ...pattern: glob, # The glob pattern to use.
] {
  let pattern = if ($pattern | is-empty) { ["."] } else { $pattern }
  (
    ls
    --all=$all
    --long=$long
    --short-names=$short_names
    --full-paths=$full_paths
    --du=$du
    --directory=$directory
    --mime-type=$mime_type
    --threads=$threads
    ...$pattern
  ) | sort-by modified | grid --separator "  " --color --width 80
}

def p [] {
  pwd | str replace $nu.home-path '~'
}

def nrs [] {
  sudo nixos-rebuild switch --flake ~/dotfiles/#(cat /etc/nixos-device-name)
}

alias "c" = cargo
alias "cat" = bat --style=plain
alias "e" = ls+
alias "g" = git
alias "i" = t "-"
alias "l" = lazygit
alias "z" = zed -a
alias "n" = hx
alias "no" = hx .
alias "sn" = sudo -E hx
alias "y" = yazi
