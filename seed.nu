# These dirs will be put into the "#" folder, and their individual files
# won't be seeded
const seed_dirs = [nushell helix bat presenterm]

# Directory where all config files are. This is available via "#", analogous for "~" for the home directory
const config_dir = $nu.default-config-dir | path dirname

# Resolves a path to its absolute location.
#
# "~" is like always the home directory, "#" is the config directory (e.g. ".config" on Linux)
def resolve-path [file: any] {
    if ($file | str starts-with "~") {
        $file | str replace "~" $nu.home-path
    } else if ($file | str starts-with "#") {
        $file | str replace "#" $config_dir
    } else {
        $file
    }
}

# Given contents of a file, reads all "path:" directives and decides
# where in the file system this file will be placed
def path-for-file [file: string] {
    mut path = null;
    for line in ($file | lines) {
        let extracted = extract-path $line
        if $extracted == null {
            break
        } else {
            $path = $extracted
        }
    }
    if $path == null {
        null
    } else {
        resolve-path $path
    }
}

# Extracts path from a line.
#
# "path.linux: ~/path"
# => "~/path" [ON LINUX]
# => null [NOT ON LINUX]
#
# "path: ~/path"
# => "~/path"
#
# "something else"
# => null
def extract-path [value: string] {
   let result = $value | parse --regex '^.*path(?:\.(?<target>.*))?: (?<path>.*)$'
   if ($result | is-empty) {
       return null;
   }
   let result = $result | get 0
   let path = $result.path
   if ($path | is-empty) {
       return null
   }
   match $result.target {
       "windows" if $nu.os-info.name == "windows" => $path
       "linux" if $nu.os-info.name == "linux" => $path
       "macos" if $nu.os-info.name == "macos" => $path
       "unix" if $nu.os-info.family == "unix" => $path
       null => $path
       _ => null
   }
}

# All files in the `dotfiles` dir that will be seeded to their locations
let all_files = ls ($"**/*" | into glob)
    # Select only files
    | where type == file
    # Get all the files as a list, rather than a table
    | get name
    # Any directory that we'll manually seed will be filtered
    | where {
        |file| not (
            $seed_dirs | any {
                |dir| $file | str starts-with $dir
            }
        )
    }
    | each {{
        src: ([$env.FILE_PWD $in] | path join)
        dst: (path-for-file (open --raw $in))
    }}
    | where dst != null

$all_files
