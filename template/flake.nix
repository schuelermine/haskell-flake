{
  inputs.haskell-flake.url = "github:schuelermine/haskell-flake/b0";
  outputs = { self, nixpkgs, haskell-flake }: haskell-flake {
    inherit nixpkgs;
    name = "dummy-package";
    package = ./dummy-package.nix;
  };
}