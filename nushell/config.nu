source zoxide.nu
source catppuccin.nu

# Enable completions for external commands (ones that aren't built-in)
$env.config.completions.external.enable = true

# Use the "fish" shell for completions
$env.config.completions.external.completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {|row|
      let value = $row.value
      let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
      if ($need_quote and ($value | path exists)) {
        let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
        $'"($expanded_path | str replace --all "\"" "\\\"")"'
      } else {$value}
    }
}

# Print the command that had a non-zero exit code in pipe
$env.config.display_errors.exit_code = true

# for recording videos in a 16 * 9 resolution on a monitor of a different resolution
def spad [] {
  swaymsg gaps left all set 440
  swaymsg gaps right all set 440
}

def unspad [] {
  swaymsg gaps left all set 0
  swaymsg gaps right all set 0
}

# The prompt
$env.PROMPT_COMMAND = { || $"(ansi purple_italic)(if $env.PWD == $nu.home-path { "~" } else { $env.PWD | path split | last } )(ansi reset)" }
# A prompt which can appear on the right side of the terminal
$env.PROMPT_COMMAND_RIGHT = { || }
# Emacs mode indicator
$env.PROMPT_INDICATOR = $"(ansi black)❯ "
# Vi-normal mode indicator
$env.PROMPT_INDICATOR_VI_NORMAL = $env.PROMPT_INDICATOR
# Vi-insert mode indicator
$env.PROMPT_INDICATOR_VI_INSERT = $env.PROMPT_INDICATOR

$env.config.keybindings ++= [
  # ctrl-z to toggle foreground and background
  {
    name: unfreeze,
    modifier: control,
    keycode: char_z,
    event: {
      send: executehostcommand,
      cmd: "job unfreeze"
    },
    mode: emacs
  }
]

# disable welcome screen
$env.config.show_banner = false

$env.config.edit_mode = "vi"

$env.config.cursor_shape = {
    emacs: line,
    vi_insert: line,
    vi_normal: block
}

# catppuccin compatible colors for ls
$env.LS_COLORS = (vivid generate catppuccin-mocha)

$env.EDITOR = "vim"

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

# Command for switching directories
#
# pass all args to zoxide then list contents of the new directory
def --env --wrapped t [ ...args: string ] {
  __zoxide_z ...$args
  ls+
}

def z [
    --reuse (-r), # Re-use existing window, replacing its workspace
    ...paths: path
] {
   ^(if $nu.os-info.family == "windows" { "zed" } else { "zeditor" }) -a ...$paths
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
  sudo -E nu ~/dotfiles/dots
}

# `nix develop` with nushell
def --wrapped d [ ...args: string ] {
    nix develop ...$args --command nu --execute $"$env.PROMPT_INDICATOR = '\(ansi blue\)❯ ';$env.PROMPT_INDICATOR_VI_NORMAL = $env.PROMPT_INDICATOR;$env.PROMPT_INDICATOR_VI_INSERT = $env.PROMPT_INDICATOR;"
}

# `nix-shell` with nushell
def --wrapped ns [ ...args: string ] {
    nix-shell ...$args --run $"$env.PROMPT_INDICATOR = '\(ansi blue\)❯ ';$env.PROMPT_INDICATOR_VI_NORMAL = $env.PROMPT_INDICATOR;$env.PROMPT_INDICATOR_VI_INSERT = $env.PROMPT_INDICATOR;"
}

$env.path ++= [
    $"($nu.home-path)/.cargo/bin"
]
$env.RUST_LOG = "ERROR"

alias "paru" = paru --bottomup
alias "c" = cargo
alias "cat" = bat --style=plain
alias "e" = ls+
alias "g" = git
alias "i" = t "-"
alias "l" = lazygit
alias "y" = yazi