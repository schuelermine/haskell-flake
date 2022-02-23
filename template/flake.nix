{
  inputs.haskell-flake.url = "github:schuelermine/haskell-flake/b0";
  outputs = { self, nixpkgs, haskell-flake }:
    haskell-flake.lib.mkOutputs {
      inherit nixpkgs;
      name = "dummy-package";
      package = ./dummy-package.nix;
    };
}
