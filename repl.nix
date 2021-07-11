{}:
let
  sources = import ./nix/sources.nix {};
  haskellNix = import sources.haskellNix {};
  pkgs = import haskellNix.sources."nixpkgs-2105" haskellNix.nixpkgsArgs;
in
{
  inherit sources;
  inherit haskellNix;
  inherit pkgs;
}
