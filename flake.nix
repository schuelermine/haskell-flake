{
  outputs = { self, flake-utils }: {
    lib = {
      mkOutputs = { nixpkgs, package, name }: let preCall = import ./preCall.nix;
      in preCall (fArgs@{ ghcVersion ? "8107" }:
        flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
          let
            lib = nixpkgs.lib;
            pkgs = nixpkgs.legacyPackages.${system};
            hkgs = if ghcVersion != null then
              pkgs.haskell.packages."ghc${ghcVersion}"
            else
              pkgs.haskellPackages;
          in {
            packages.${name} = hkgs.callPackage package { };
            devShell = (self fArgs).devShells.${system}.${name};
            devShells = let
              mkDevShell = args:
                pkgs.mkShellNoCC ({
                  inputsFrom = [ (self fArgs).packages.${system}.${name} ];
                } // args);
            in {
              ${name} = mkDevShell { };
              withCabal =
                mkDevShell { packages = with pkgs; [ cabal-install ]; };
              withStack = mkDevShell { packages = with pkgs; [ stack ]; };
              editorWithCabalHls = preCall ({ editor ? null }:
                mkDevShell {
                  buildInputs = lib.optional (editor != null) editor
                    ++ (with pkgs; [ cabal-install haskell-language-server ]);
                });
            };
          }));
    };
  };
}
