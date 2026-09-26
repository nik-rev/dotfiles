Installing graphical applications via flatpak:

```sh
flatpak --user install flathub <application>
```

Sync the list of packages:

```sh
sh sync-packages.sh
```

Install packages:

```sh
sudo rpm-ostree install <package>
# then reboot: `systemctl reboot`
```
