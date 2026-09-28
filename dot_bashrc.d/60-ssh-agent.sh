# Fedora ships ssh-agent but leaves it off. The dotfiles turn it on (see
# ~/.config/systemd/user/sockets.target.wants), and this tells everything
# where to find it. Like the PATH, apps started from the desktop get it too.
# Over SSH, keep the agent that was forwarded from the other machine
if [ -z "${SSH_CONNECTION:-}" ] && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi
