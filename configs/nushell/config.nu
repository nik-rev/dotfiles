source zoxide.nu
# carapace _carapace nushell o> configs/nushell/carapace.nu
source carapace.nu
source atuin.nu
source catppuccin.nu

# Command for switching directories
# 
# pass all args to zoxide then list contents of the new directory
def --env --wrapped t [ ...args: string ] {
  z ...$args
  ^ls --classify --reverse --time=mtime --color=always --width 80
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
    $"($env.home)/.cargo/bin"
]

$env.PROMPT_COMMAND = ""
$env.PROMPT_INDICATOR = { || $"(ansi purple_italic)($env.PWD | path split | last)(ansi reset)$ " }
$env.PROMPT_COMMAND_RIGHT = { || }

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

# catppuccin compatible colors for ls
$env.LS_COLORS = (vivid generate catppuccin-mocha)

def --env o [] {
  cd ..
  ^ls --classify --reverse --time=mtime --color=always --width 80
}

def --env oo [] {
  cd ../..
  ^ls --classify --reverse --time=mtime --color=always --width 80
}

def --env ooo [] {
  cd ../../..
  ^ls --classify --reverse --time=mtime --color=always --width 80
}

def --env oooo [] {
  cd ../../../..
  ^ls --classify --reverse --time=mtime --color=always --width 80
}

def --env ooooo [] {
  cd ../../../../..
  ^ls --classify --reverse --time=mtime --color=always --width 80
}

def p [] {
  pwd | str replace $env.HOME '~'
}

# toggle primary monitor on/off
alias "toggle" = swaymsg output eDP-1 toggle 
alias "c" = cargo
alias "cat" = bat --style=plain
alias "e" = ^ls --classify --reverse --time=mtime --color=always --width 80
alias "g" = git
alias "i" = t "-"
alias "icat" = wezterm imgcat
alias "l" = lazygit
alias "lg" = lazygit
alias "n" = hx
alias "g" = git
alias "no" = hx .
alias "nrs" = sudo nixos-rebuild switch
alias "sn" = sudo -E hx
alias "y" = yazi
