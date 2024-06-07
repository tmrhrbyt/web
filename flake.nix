{
  description = "My website";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (sys:  
      let pkgs = nixpkgs.legacyPackages.${sys};
          deps = import ./deps.nix { inherit pkgs; };
      in {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            export EXECJS_RUNTIME=Node
          '';
          packages = deps;
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "tamar.cc";
          buildInputs = deps;
          src = ./.;
          buildPhase = ''
            EXECJS_RUNTIME=Node JEKYLL_ENV=production jekyll build -d $out
          '';
        };
      });
}
