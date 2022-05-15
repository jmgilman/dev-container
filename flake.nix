{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        checkCommit = pkgs.writeShellScriptBin "checkCommit" ''
          cog verify "$(cat $1)"
        '';
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              commit-check = {
                enable = true;
                name = "Check commit message";
                entry = "checkCommit";
                language = "system";
                stages = [ "commit-msg" ];
              };
            };
          };
        };
        devShell = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          packages = [
            checkCommit
            pkgs.hadolint
            pkgs.cocogitto
          ];
        };
      }
    );
}
