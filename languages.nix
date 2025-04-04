{ pkgs, ... }:
{
  programs.go = {
    enable = true;
    goBin = "go/bin";
  };
  home.packages = with pkgs.u; [
    ### typst
    typst # compiler
    typstyle # formatter
    tinymist # language server

    ### asm
    asm-lsp

    ### go
    gopls # language server
    gofumpt # formatter
    hugo # static site generator

    ### rust
    rustup # install everything Rust
    zola # static site generator
    # remove unused dependencies
    cargo-udeps

    ### nix
    nil # language server
    nixfmt-rfc-style # formatter

    ### lua
    stylua # formatter

    ### shell
    bash-language-server
    shfmt # formatter

    ### c
    clang
    cmake
    gnumake
    clang-tools
    mold
    vcpkg # package manager
    bear # for c sharp language server in order to discover the header files

    ### haskell

    haskell-language-server
    ormolu # formatter
    stack
    cabal-install
    hpack
    ghc # compiler

    ### javascript
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
}
