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
      # dioxus-cli

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
    # llvm
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
    yazi.enable = true;
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
        bat
        sof-firmware
        ripgrep
        libreoffice
        xclip
        # google-chrome
        p7zip
        exercism
        zathura
        # inputs.patchy.packages.${pkgs.system}.default
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
        direnv
        postgresql
        vial
        pgcli
        nixpkgs-review
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
