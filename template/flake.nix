{
  inputs.haskell-flake = {
    url = "github:schuelermine/haskell-flake/b0";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, haskell-flake }:
    haskell-flake.lib.mkOutputs {
      inherit self nixpkgs;
      name = "dummy-package";
      package = ./dummy-package.nix;
    };
}
