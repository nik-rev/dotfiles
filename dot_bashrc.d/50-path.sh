# The PATH on Linux. Fedora's ~/.bashrc loads everything in ~/.bashrc.d, and
# COSMIC takes the environment for the whole desktop session from bash as a
# login shell, so apps started from the desktop get this PATH too. These go
# after the system directories so they never shadow system commands
for dir in "$HOME/.local/bin" "$HOME/.pixi/bin"; do
    case ":$PATH:" in
        *":$dir:"*) ;;
        *) PATH="$PATH:$dir" ;;
    esac
done
export PATH
