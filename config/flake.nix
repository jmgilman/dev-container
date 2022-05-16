{
  description = "Configuration of vscode";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { home-manager, ... }:
    let
      system = "ARCH";
      username = "USER";
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        # Specify the path to your home configuration here
        configuration = import ./config.nix;
        extraModules = map (n: "${./extra}/${n}") (builtins.attrNames (builtins.readDir ./extra));

        inherit system username;
        homeDirectory = "/home/${username}";
      };
    };
}
