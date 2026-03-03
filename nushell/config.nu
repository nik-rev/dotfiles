source zoxide.nu
source catppuccin.nu

use std/clip copy
use std bench
use std/iter intersperse
use std repeat

# When printing any kind of link in the terminal, make it openable in Zed
alias rg = ^rg --hyperlink-format="zed://file{path}:{line}:{column}"

alias vm = sudo virsh --connect=qemu:///system

def "vm open" [domain: string] {
    remote-viewer (vm domdisplay $domain)
}

def "vm launch" [domain: string] {
    vm start $domain
    vm open $domain
}

# When changing the working directory, show contents of the new directory
$env.config.hooks.env_change.PWD ++= [{ |old_dir, new_dir|
    print (ls+)
}]

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

# More compact errors
$env.config.error_style = "short"

# Enable completions for external commands (commands that aren't built-in)
$env.config.completions.external.enable = true

# The prompt
$env.PROMPT_COMMAND = { || $"(ansi purple_italic)(if $env.PWD == $nu.home-dir { "~" } else { $env.PWD | path split | last } )(ansi reset)" }
# A prompt which can appear on the right side of the terminal
$env.PROMPT_COMMAND_RIGHT = { || }
# Emacs mode indicator
$env.PROMPT_INDICATOR = $"(ansi black)❯ "
# Vi-normal mode indicator
$env.PROMPT_INDICATOR_VI_NORMAL = $env.PROMPT_INDICATOR
# Vi-insert mode indicator
$env.PROMPT_INDICATOR_VI_INSERT = $env.PROMPT_INDICATOR

# disable welcome screen
$env.config.show_banner = false

$env.config.edit_mode = "vi"

$env.config.cursor_shape.vi_insert = "line"

# catppuccin compatible colors for ls
$env.LS_COLORS = (vivid generate catppuccin-mocha)

$env.EDITOR = "vim"

# Commands for going to parent directories

def --env o [] { cd .. }
def --env oo [] { cd ../.. }
def --env ooo [] { cd ../../.. }
def --env oooo [] { cd ../../../.. }
def --env ooooo [] { cd ../../../../.. }

alias t = __zoxide_z

def n [
    --reuse (-r), # Re-use existing window, replacing its workspace
    --add (-a), # Add files to an existing workspace
    ...paths: path
] {
    ^(if $nu.os-info.family == "windows" { "zed" } else { "zeditor" }) --add=$add --reuse=$reuse ...$paths
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

$env.path ++= [
    $"($nu.home-dir)/.cargo/bin"
    $"($nu.home-dir)/.local/bin"
]
$env.RUST_LOG = "ERROR"

alias paru = paru --bottomup
alias c = cargo
alias cat = bat --style=plain
alias e = ls+
alias g = git
alias i = t "-"
alias r = zi
alias l = lazygit
alias y = yazi
