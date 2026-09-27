# PATH on Linux. Fedora's ~/.bashrc loads the files in ~/.bashrc.d, and
# COSMIC takes the environment of the whole desktop session from bash as a
# login shell, so apps started from the desktop get this PATH too.
# After the system directories, so these never shadow system commands
for dir in "$HOME/.local/bin" "$HOME/.pixi/bin"; do
    case ":$PATH:" in
        *":$dir:"*) ;;
        *) PATH="$PATH:$dir" ;;
    esac
done
export PATH
