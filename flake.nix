{
  description = "morpheus-graphql with meta-introspector th-desugar";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    th-desugar-src = {
      url = "github:meta-introspector/th-desugar/rename";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, th-desugar-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        haskellPackages = pkgs.haskell.packages.ghc96;

        morpheus-src = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type:
            let baseName = baseNameOf path;
            in !(builtins.elem baseName [ "dist-newstyle" ".stack-work" "result" ]);
        };

        hpkgs = haskellPackages.override {
          overrides = hself: hsuper: {
            th-desugar = hself.callCabal2nix "th-desugar" th-desugar-src {};
            morpheus-graphql-core = hself.callCabal2nix "morpheus-graphql-core" (morpheus-src + "/morpheus-graphql-core") {};
            morpheus-graphql-app = hself.callCabal2nix "morpheus-graphql-app" (morpheus-src + "/morpheus-graphql-app") {};
            morpheus-graphql-server = hself.callCabal2nix "morpheus-graphql-server" (morpheus-src + "/morpheus-graphql-server") {};
            morpheus-graphql-client = hself.callCabal2nix "morpheus-graphql-client" (morpheus-src + "/morpheus-graphql-client") {};
            morpheus-graphql-subscriptions = hself.callCabal2nix "morpheus-graphql-subscriptions" (morpheus-src + "/morpheus-graphql-subscriptions") {};
            morpheus-graphql-code-gen = hself.callCabal2nix "morpheus-graphql-code-gen" (morpheus-src + "/morpheus-graphql-code-gen") {};
            morpheus-graphql-code-gen-utils = hself.callCabal2nix "morpheus-graphql-code-gen-utils" (morpheus-src + "/morpheus-graphql-code-gen-utils") {};
            morpheus-graphql = hself.callCabal2nix "morpheus-graphql" (morpheus-src + "/morpheus-graphql") {};
            morpheus-graphql-tests = hself.callCabal2nix "morpheus-graphql-tests" (morpheus-src + "/morpheus-graphql-tests") {};
          };
        };
      in {
        packages.default = hpkgs.morpheus-graphql-server;

        packages.core = hpkgs.morpheus-graphql-core;
        packages.app = hpkgs.morpheus-graphql-app;
        packages.client = hpkgs.morpheus-graphql-client;

        devShells.default = hpkgs.shellFor {
          packages = p: [
            p.morpheus-graphql-core
            p.morpheus-graphql-app
            p.morpheus-graphql-server
          ];
          buildInputs = [
            hpkgs.cabal-install
            hpkgs.haskell-language-server
          ];
        };
      });
}
