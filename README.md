These dotfiles are unlike most others: They work on Windows, MacOS and Linux.

This is made possible using a custom [script](dots) that copies every file and directory
to its destination.

Some configs are as simple as "copy this file `kitty.conf` to the `$CONFIG_DIR/kitty` directory"
others are more complex, like using a directory called `Zed` rather than `zed` on Windows. Or firefox `user.js` location, which lives in the profile directory, which has a randomly generated name.

These rules become increasingly hard to follow with a dedicated general-purpose binary for managing dotfiles,
but given a specialized script it becomes very simple.

# Linux Fonts

This repository contains a bunch of fonts for a working system: <https://github.com/hazelshantz/Font-Collection/tree/main>
