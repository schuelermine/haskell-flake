{
  description = "A reusable flake output format for haskell packages";
  outputs = { flake-utils, self }: {
    defaultTemplate = self.templates.haskell-flake;
    templates.haskell-flake = {
      path = ./template;
      description = "A flake using haskell-flake";
    };
    lib = {
      mkOutputs = { nixpkgs, package, systems ? flake-utils.lib.defaultSystems
        , name, defaultGhcVersion ? "8107", self }:
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
              defaultPackage =
                self.packages.${system}.default; # defaultPackage is deprecated as of Nix 2.7.0
              packages = rec {
                default = hkgs.callPackage package { };
                ${name} = default;
              };
              devShell =
                self.devShells.${system}.default; # devShell is deprecated as of Nix 2.7.0
              devShells = let
                mkDevShell = args:
                  pkgs.mkShellNoCC ({
                    inputsFrom = [ self.packages.${system}.${name} ];
                  } // args);
              in rec {
                default = mkDevShell { };
                ${name} = default;
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
