# auto-start environment on login
if [ "$(tty)" = "/dev/tty1" ]; then
    exec sway --unsupported-gpu
fi
