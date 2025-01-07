{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    stacklock2nix.url = "github:cdepillabout/stacklock2nix";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem = { pkgs, system, ... }:
      let
        overlays = [
          inputs.stacklock2nix.overlay
          (final: prev:
            let
              ghc = final.haskell.packages.ghc984;
            in
            {
            test-stack = final.stacklock2nix {
              stackYaml = ./stack.yaml;
              baseHaskellPkgSet = ghc;
              additionalDevShellNativeBuildInputs = stacklockHaskellPkgSet: [
                final.stack
                final.nil
              ];
            };
          })
        ];
      in
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system overlays;
        };

        packages = {
          inherit (pkgs.test-stack.pkgSet) test-stack;
          default = pkgs.test-stack.pkgSet.test-stack;
        };

        devShells.default = pkgs.test-stack.devShell;
      };
    };
}
