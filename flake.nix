{
  description = "Meta-Introspector: Agda→TH→GHC→GraphQL→MetaCoq→Coq→OCaml→LLVM→Rust quine pipeline";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    # th-desugar: our fork (rename branch) and upstream releases
    th-desugar-fork = { url = "github:meta-introspector/th-desugar/rename"; flake = false; };
    th-desugar-1_19 = { url = "github:goldfirere/th-desugar/v1.19"; flake = false; };
    th-desugar-1_17 = { url = "github:goldfirere/th-desugar/v1.17"; flake = false; };

    # ocaml-llvm bridge
    ocamlllvm-src = { url = "github:yzhs/ocamlllvm"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils
            , th-desugar-fork, th-desugar-1_19, th-desugar-1_17
            , ocamlllvm-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # GHC versions
        ghc96 = pkgs.haskell.packages.ghc96;
        ghc98 = pkgs.haskell.packages.ghc98 or ghc96;

        morpheus-src = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type:
            let b = baseNameOf path;
            in !(builtins.elem b [ "dist-newstyle" ".stack-work" "result" ".git" ]);
        };

        # Build morpheus + th-desugar for a given GHC package set and th-desugar source
        mkMorpheus = hpkgs: thSrc: hpkgs.override {
          overrides = hself: hsuper: {
            th-desugar = hself.callCabal2nix "th-desugar" thSrc {};
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

        # Matrix: GHC × th-desugar version
        ghc96-fork = mkMorpheus ghc96 th-desugar-fork;
        ghc96-v1_19 = mkMorpheus ghc96 th-desugar-1_19;
        ghc96-v1_17 = mkMorpheus ghc96 th-desugar-1_17;

      in {
        # Default: GHC 9.6 + our th-desugar fork
        packages.default = ghc96-fork.morpheus-graphql-server;

        # Multi-version matrix
        packages.core-fork = ghc96-fork.morpheus-graphql-core;
        packages.core-v1_19 = ghc96-v1_19.morpheus-graphql-core;
        packages.core-v1_17 = ghc96-v1_17.morpheus-graphql-core;

        # Pipeline tools
        packages.pipeline-tools = pkgs.buildEnv {
          name = "meta-introspector-pipeline";
          paths = [
            pkgs.agda                    # Agda → Haskell
            ghc96-fork.ghc               # GHC with LLVM backend
            pkgs.coq                     # Coq/MetaCoq
            pkgs.ocaml                   # OCaml extraction target
            pkgs.llvmPackages_17.llvm    # LLVM IR tools
            pkgs.lean4                   # Lean4
            pkgs.rustc                   # Rust
            pkgs.gcc                     # GCC
          ];
        };

        devShells.default = ghc96-fork.shellFor {
          packages = p: [
            p.morpheus-graphql-core
            p.morpheus-graphql-app
            p.morpheus-graphql-server
          ];
          buildInputs = with pkgs; [
            ghc96-fork.cabal-install
            agda
            coq
            ocaml
            llvmPackages_17.llvm
          ];
        };
      });
}
