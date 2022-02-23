{ mkDerivation, base, lib }:
mkDerivation {
  pname = "dummy-package";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base ];
  homepage = "https://example.com";
  description = "A dummy package";
  license = lib.licenses.mit;
}
