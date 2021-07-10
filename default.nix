{ compiler-nix-name ? "ghc8105" }:
let
  sources = import ./nix/sources.nix {};
  haskellNix = import sources.haskellNix {};
  pkgs = import haskellNix.sources."nixpkgs-2105" haskellNix.nixpkgsArgs;
  project = pkgs.haskell-nix.cabalProject {
    inherit compiler-nix-name;
    src = pkgs.haskell-nix.haskellLib.cleanGit { src = ./.; name = "anybolt"; };
  };
in
  project // {
    shell = project.shellFor {
      tools = {
        cabal = "latest";
        hlint = "latest";
        haskell-language-server = "latest";
      };
      buildInputs = [
        pkgs.nix-prefetch-git
        pkgs.haskellPackages.hie-bios
      ];
    };
  }
