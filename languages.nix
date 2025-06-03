{ pkgs, ... }:
{
  programs.go = {
    enable = true;
    goBin = "go/bin";
  };
  home.packages = with pkgs.u; [
    ### markdown
    typos # spell checker
    typos-lsp # spell checker markdown LSP

    ### typst
    typst # compiler
    typstyle # formatter
    tinymist # language server

    ### rust
    rustup # install everything Rust
    zola # static site generator

    ### nix
    nil # language server
    nixfmt-rfc-style # formatter

    # to be able to view built static websites on localhost
    live-server
  ];
}
