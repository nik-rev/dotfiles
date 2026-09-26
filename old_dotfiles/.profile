# auto-start environment on login
if [ "$(tty)" = "/dev/tty1" ]; then
    start-cosmic
fi
