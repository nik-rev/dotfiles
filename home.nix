# git add -N flake.nix flake.lock and then git update-index --skip-worktree flake.nix flake.lock

# ^ for work, since they don't allow me to commit my flake.nix file.

{
  pkgs,
  config,
  pkgs-unstable,
  inputs,
  ...
}:
let
  haskell_ = with pkgs-unstable; [
    haskell-language-server
    ormolu
    stack
    cabal-install
    hpack
    ghc
  ];
  csharp = with pkgs-unstable; [
    # dotnet-sdk_9
    dotnet-sdk
    dotnet-ef
    # lang server
    omnisharp-roslyn
    # formatter
    csharpier
  ];
  typst_ = with pkgs-unstable; [
    typst
    typstyle
    tinymist
  ];
  go = with pkgs-unstable; [
    gopls
    gofumpt
  ];
  misc = with pkgs-unstable; [
    nginx-language-server
    nginx
    gnumake
  ];
  # elixir = with pkgs-unstable; [
  #   elixir_1_16
  #   elixir-ls
  # ];
  python = with pkgs-unstable; [
    python3
    pipx
    ruff
    pyright
  ];
  rust =
    with pkgs-unstable;
    [
      rustup

      # some crates require openssl
      # see also https://github.com/sfackler/rust-openssl/issues/1663
      libiconv
      openssl
      pkg-config

      # frameworks
      zola

    ]
    ++ (with pkgs; [

      # tauri and dioxus: https://tauri.app/start/prerequisites/#linux
      cargo-tauri
      gobject-introspection
      at-spi2-atk
      atkmm
      cairo
      glib
      gtk3
      harfbuzz
      librsvg
      libsoup_3
      pango
      webkitgtk_4_1

    ]);
  nix = with pkgs-unstable; [
    nil
    nixfmt-rfc-style
  ];
  lua = with pkgs-unstable; [ stylua ];
  shell = with pkgs-unstable; [
    bash-language-server
    shfmt
  ];
  javascript = with pkgs-unstable; [
    typescript-language-server
    turbo
    tailwindcss_4
    tailwindcss-language-server
    svelte-language-server
    vscode-langservers-extracted
    astro-language-server
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
  ];
  c = with pkgs-unstable; [
    clang
    cmake
    # llvmPackages_19.libllvm
    clang-tools
    mold
    # package manager
    vcpkg
    # for c sharp language server in order to discover the header files
    bear
    ninja
    # conan
  ];
in
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
    gitui = {
      enable = true;
      theme = ''
        (
            selected_tab: Some("Reset"),
            command_fg: Some("#cdd6f4"),
            selection_bg: Some("#585b70"),
            selection_fg: Some("#cdd6f4"),
            cmdbar_bg: Some("#181825"),
            cmdbar_extra_lines_bg: Some("#181825"),
            disabled_fg: Some("#7f849c"),
            diff_line_add: Some("#a6e3a1"),
            diff_line_delete: Some("#f38ba8"),
            diff_file_added: Some("#a6e3a1"),
            diff_file_removed: Some("#eba0ac"),
            diff_file_moved: Some("#cba6f7"),
            diff_file_modified: Some("#fab387"),
            commit_hash: Some("#b4befe"),
            commit_time: Some("#bac2de"),
            commit_author: Some("#74c7ec"),
            danger_fg: Some("#f38ba8"),
            push_gauge_bg: Some("#89b4fa"),
            push_gauge_fg: Some("#1e1e2e"),
            tag_fg: Some("#f5e0dc"),
            branch_fg: Some("#94e2d5")
        )'';
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
    sessionPath = [
      # "$HOME/.cache/npm/global/bin"
      # "$HOME/.cargo/bin"
    ];
    pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    packages =
      with pkgs;
      [
        # virtual machine for Windows
        quickemu
        sof-firmware
        ripgrep
        libreoffice
        xclip
        # google-chrome
        p7zip
        exercism
        zathura
        brightnessctl
        gimp
        catppuccin-whiskers
        just
        # generates LS_COLORS
        vivid
        onefetch
        imagemagick
        # sound control
        pamixer
        # otherwise playwright will not work
        # chromium
      ]
      ++ (with pkgs-unstable; [
        # for recordings
        gnome-terminal
        wl-clipboard
        playwright-test
        doggo
        jq
        zip
        unzip
        virt-manager
        # playwright-driver
        dconf
        hugo
        gh
        asciinema
        # interactive search and replace
        scooter
        # benchmarking tool
        hyperfine
        # take screenshots
        slurp
        # copy slurp screenshots to clipboard
        grim
        mesa
        tree

        # when using standard nix-shell all my configurations are lost
        # with this tool, that isn't the case anymore
        postgresql
        # llvm
        vial
        # screen recording
        # obs-studio
        # # capture screen on wayland
        # obs-studio-plugins.wlrobs
        pgcli
        mpv
        # vlc
        nixpkgs-review
        # spell checker
        typos
        typos-lsp
        # alsa-lib.dev
        alsa-lib
        # utility to view battery percentage
        acpi
        tree-sitter
        leetgo
        # debugger
        lldb
        # difftool
        difftastic
        # telegram
        telegram-desktop
        # unzip .rar files
        unar
        # lspci
        fastfetch
        pciutils
        slack
        vscode
      ])
      ++ haskell_
      ++ rust
      ++ nix
      ++ lua
      ++ c
      ++ csharp
      ++ shell
      ++ javascript
      ++ go
      ++ python
      ++ misc
      ++ typst_;
    stateVersion = "24.11";
  };
}
