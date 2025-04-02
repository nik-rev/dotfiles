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
    ./git.nix
    ./nu.nix
    ./sway.nix
  ];

  # disable update check for pnpm
  xdg.configFile."pnpm/rc".source =
    let
      keyValue = pkgs.formats.keyValue { };
    in
    keyValue.generate "rc" { update-notifier = false; };
  xdg.userDirs.download = "${config.home.homeDirectory}/t";
  xdg.configFile."rio/config.toml".source = ./rio.toml;

  # ssh
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    includes = [ "~/.ssh/id_ed25519" ];
  };

  programs = {
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
        )
      '';
    };
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
        asm = with pkgs-unstable; [
          asm-lsp
        ];
        go = with pkgs-unstable; [
          gopls # language server
          gofumpt # formatter
          hugo # static site generator
        ];
        rust = with pkgs-unstable; [
          rustup # install everything Rust
          zola # static site generator
          # remove unused dependencies
          cargo-udeps
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
        rio
        p7zip
        inputs.zen-browser.packages.${pkgs.system}.default
        imagemagick
        aider-chat
        act # local github CI runner
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
      ]
      ++ haskell_
      ++ rust
      ++ nix
      ++ lua
      ++ c
      ++ shell
      ++ javascript
      ++ asm
      ++ go
      ++ typst_;
    stateVersion = "24.11";
  };
}
