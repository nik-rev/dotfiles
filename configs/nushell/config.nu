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
  ^ls --classify --color=always
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

# Clone in an ergonomic way
def --env clone [ $owner, $repo ] {
  let clone_dir = match $owner {
      "nik-contrib" => "contrib",
      "nik-rev" => "projects",
      _ => "repos"
  }

  let $repo_dir = $"($env.HOME)/($clone_dir)/($repo)"
  mkdir $clone_dir
  gix clone $"git@github.com:($owner)/($repo).git" $repo_dir o> /dev/null
  cd $repo_dir
}

$env.path ++= [
    $"($env.home)/.cargo/bin"
]

$env.PROMPT_COMMAND_RIGHT = {||
  let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
      null => $env.PWD
      '\' => '~'
      $relative_pwd => ([~ $relative_pwd] | path join)
  }

  let path_segment = $"(ansi blue)($dir)(ansi reset)"

  $path_segment | str replace --all (char path_sep) $"(ansi white)(char path_sep) (ansi blue)"
}

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

$env.PROMPT_COMMAND = ""

$env.config.show_banner = false

# catppuccin compatible colors for ls
$env.LS_COLORS = (vivid generate catppuccin-mocha)

def --env o [] {
  cd ..
  ^ls --classify -rt --color=always
}

def --env oo [] {
  cd ../..
  ^ls --classify -rt --color=always
}

def --env ooo [] {
  cd ../../..
  ^ls --classify -rt --color=always
}

def --env oooo [] {
  cd ../../../..
  ^ls --classify -rt --color=always
}

def --env ooooo [] {
  cd ../../../../..
  ^ls --classify -rt --color=always
}

def --env yy [...args] {
  let tmp = (mktemp -t "yazi-cwd.XXXXX")
  yazi ...$args --cwd-file $tmp
  let cwd = (open $tmp)
  if $cwd != "" and $cwd != $env.PWD {
    cd $cwd
  }
  rm -fp $tmp
}

alias "c" = cargo
alias "cat" = bat --style=plain
alias "e" = ^ls --classify -rt --color=always
alias "g" = git
alias "icat" = wezterm imgcat
alias "l" = lazygit
alias "lg" = lazygit
alias "n" = hx
alias "no" = hx .
alias "nrs" = sudo nixos-rebuild switch
alias "sn" = sudo -E hx
alias "y" = yazi
