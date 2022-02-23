{
  description = "A reusable flake output format for haskell packages";
  outputs = { self, flake-utils }: {
    templates.haskell-flake = {
      path = ./template;
      description = "A flake using haskell-flake";
    };
    lib = {
      mkOutputs = { nixpkgs, package, systems ? flake-utils.lib.defaultSystems, name, defaultGhcVersion ? "8107" }:
        let preCall = import ./preCall.nix;
        in preCall (fArgs@{ ghcVersion ? defaultGhcVersion }:
          flake-utils.lib.eachSystem systems (system:
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
