{ pkgs, pkgs-unstable, ... }:
let
  haskell_ = with pkgs-unstable; [
    haskell-language-server
    ormolu
    stack
    cabal-install
    hpack
    ghc
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
  rust = with pkgs-unstable; [
    rustup

    # some crates require openssl
    # see also https://github.com/sfackler/rust-openssl/issues/1663
    libiconv
    openssl
    pkg-config
  ];
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
  ];
  c = with pkgs-unstable; [
    clang
    clang-tools
    mold
  ];
in
{
  home.packages = haskell_ ++ rust ++ nix ++ lua ++ c ++ shell ++ javascript ++ go ++ python ++ misc;

  # disable update check for pnpm
  xdg.configFile."pnpm/rc".source =
    let
      keyValue = pkgs.formats.keyValue { };
    in
    keyValue.generate "rc" { update-notifier = false; };
}
