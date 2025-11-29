# auto-start Sway on login
if [ "$(tty)" = "/dev/tty1" ]; then
    exec niri-session
fi
