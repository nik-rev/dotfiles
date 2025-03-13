# git add -N flake.nix flake.lock and then git update-index --skip-worktree flake.nix flake.lock

# ^ for work, since they don't allow me to commit my flake.nix file.

{
  pkgs,
  config,
  pkgs-unstable,
  inputs,
  ...
}:

{
  imports = [
    ./helix.nix
    ./firefox.nix
    ./git.nix
    ./lazygit.nix
    ./nu.nix
    ./sway.nix
  ];

  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  # disable update check for pnpm
  xdg.configFile."pnpm/rc".source =
    let
      keyValue = pkgs.formats.keyValue { };
    in
    keyValue.generate "rc" { update-notifier = false; };
  xdg.userDirs.download = "${config.home.homeDirectory}/t";
  programs = {
    yazi = {
      enable = true;
      package = inputs.yazi.packages.${pkgs.system}.yazi;
    };
    bat = {
      enable = true;
      config = {
        theme = "catppuccin";
      };
      themes = {
        catppuccin = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          };
          file = "Catppuccin-mocha.tmTheme";
        };
      };
    };
    zoxide.enable = true;
    wezterm = {
      enable = true;
      # currently, rendering is broken in the new wezterm versions https://github.com/NixOS/nixpkgs/issues/336069
      package = inputs.wezterm.packages.${pkgs.system}.default;
    };
    ripgrep.enable = true;
    fzf.enable = true;
    fd.enable = true;
    go.enable = true;
    go.goBin = "go/bin";
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        droidcam-obs
      ];
    };
  };
  home = {
    pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    packages =
      let
        haskell_ = with pkgs-unstable; [
          haskell-language-server
          ormolu # formatter
          stack
          cabal-install
          hpack
          ghc # compiler
        ];
        typst_ = with pkgs-unstable; [
          typst # compiler
          typstyle # formatter
          tinymist # language server
        ];
        go = with pkgs-unstable; [
          gopls # language server
          gofumpt # formatter
          hugo # static site generator
        ];
        rust = with pkgs-unstable; [
          rustup # install everything Rust
          zola # static site generator
        ];
        nix = with pkgs-unstable; [
          nil # language server
          nixfmt-rfc-style # formatter
        ];
        lua = with pkgs-unstable; [
          stylua # formatter
        ];
        shell = with pkgs-unstable; [
          bash-language-server
          shfmt # formatter
        ];
        javascript = with pkgs-unstable; [
          turbo
          tailwindcss_4
          pnpm
          nodejs
          deno
          prettierd
          taplo
          typescript
          biome
          nodePackages."@astrojs/language-server"
          nodePackages.prettier
          # to be able to view built static websites on localhost
          live-server
          # INFO: to globally install npm packages use the following two commands:
          # npm config set prefix "${HOME}/.cache/npm/global"
          # mkdir -p "${HOME}/.cache/npm/global"
          # after this we can run npm install -g <pkg>
          #
          # Installed packages this way:
          # @mdx-js/language-server
          # prettier-plugin-astro
          # prettier-plugin-svelte
          # language servers
          typescript-language-server
          tailwindcss-language-server
          svelte-language-server
          vscode-langservers-extracted
          astro-language-server
        ];
        c = with pkgs-unstable; [
          clang
          cmake
          gnumake
          clang-tools
          mold
          vcpkg # package manager
          bear # for c sharp language server in order to discover the header files
        ];
      in
      with pkgs-unstable;
      [
        sof-firmware
        p7zip
        imagemagick
        just # command runner
        brightnessctl # control brightness
        quickemu # painless virtual machines
        zathura # document viewer (e.g. PDF)
        libreoffice # document viewer suite
        onefetch # repository information
        pamixer # sound control
        gimp # image editor
        vivid # generates LS_COLORS
        wl-clipboard
        doggo # dns CLI
        dconf
        gh # GitHub CLI
        scooter # mass search and replace
        hyperfine # benchmarking tool
        slurp # take screenshots (wayland wl-roots)
        grim # copy slurp screenshots to clipboard (wayland wl-roots)
        tree # tree view of files
        vial # keyboard configurator
        mpv # video player
        typos # spell checker
        typos-lsp # spell checker markdown LSP
        acpi # utility to view battery percentage
        leetgo # leetcode using Helix editor
        unar # unzip .rar files
        pciutils # view connected PCI devices
        telegram-desktop
        slack
      ]
      ++ haskell_
      ++ rust
      ++ nix
      ++ lua
      ++ c
      ++ shell
      ++ javascript
      ++ go
      ++ typst_;
    stateVersion = "24.11";
  };
}
