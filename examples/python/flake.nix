{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix-src.url = github:jmgilman/poetry2nix;
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ poetry2nix-src.overlay ];
        };

        project = pkgs.poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          python = pkgs.python39;
          preferWheels = true;
          overrides = [
            pkgs.poetry2nix.defaultPoetryOverrides
          ];
        };
      in {
        devShell = pkgs.mkShell {
          packages = [
            project
            pkgs.poetry
          ];
        };
      }
    );
}