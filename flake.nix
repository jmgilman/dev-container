{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-pre-commit.url = "github:jmgilman/nix-pre-commit";
  };

  outputs = { self, nixpkgs, flake-utils, nix-pre-commit }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Inherit system packages
        pkgs = import nixpkgs {
          inherit system;
        };

        # Configure home-manager overrides
        hm = pkgs.lib.generators.toPretty { } {
          programs.zsh = {
            envExtra = ''
              # Custom functions
              cmt() {
                git commit -m "$1: $2"
              }
            '';
          };
        };

        # Create a wrapper for enforcing conventional commit messages
        checkCommit = pkgs.writeShellScriptBin "checkCommit" ''
          cog verify "$(cat $1)"
        '';

        # Define pre-commit config
        config = {
          repos = [
            {
              repo = "local";
              hooks = [
                {
                  id = "check-commit";
                  entry = "${checkCommit}/bin/checkCommit";
                  language = "system";
                  stages = [ "commit-msg" ];
                }
                {
                  id = "hadolint";
                  entry = "${pkgs.hadolint}/bin/hadolint";
                  language = "system";
                  files = "Dockerfile";
                }
                {
                  id = "nixpkgs-fmt";
                  entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
                  language = "system";
                  files = "\\.nix";
                }
                {
                  id = "prettier";
                  entry = "${pkgs.nodePackages.prettier}/bin/prettier";
                  language = "system";
                  types_or = [ "markdown" "yaml" ];
                }
              ];
            }
          ];
        };
        configHook = (nix-pre-commit.lib.${system}.mkConfig {
          inherit pkgs config;
        }).shellHook;
      in
      {
        # Configure development environment
        devShell = pkgs.mkShell {
          shellHook = ''
            ${configHook}
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
            pkgs.cocogitto
            pkgs.pre-commit
          ];
        };
      }
    );
}
