{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Inherit system packages
        pkgs = import nixpkgs {
          inherit system;
        };

        # Configure home-manager overrides
        hm = pkgs.lib.generators.toPretty {} {
          programs.zsh = {
            envExtra = ''
              # Custom functions
              cc() {
                cog commit $@ && git commit --amend --no-edit
              }
            '';
          };
        };

        # Create a wrapper for enforcing conventional commit messages
        checkCommit = pkgs.writeShellScriptBin "checkCommit" ''
          cog verify "$(cat $1)"
        '';
      in
      {
        # Add custom pre-commit checks
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

        # Configure development environment
        devShell = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check);
          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}
            # Push local home-manager config to filesystem
            cat << 'EOT' > /tmp/local.nix
            { config, pkgs, ... }:
              ${hm}
            EOT

            # If something has changed, replace the config and call switch
            if ! cmp --silent -- /tmp/local.nix ~/.config/devcontainer/extra/local.nix; then
              cp /tmp/local.nix ~/.config/devcontainer/extra/local.nix
              home-manager switch --flake ~/.config/devcontainer#vscode
            fi
          '';
          packages = [
            checkCommit
            pkgs.cocogitto
            pkgs.hadolint
          ];
        };
      }
    );
}
