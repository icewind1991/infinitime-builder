{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/release-23.11";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
  utils.lib.eachDefaultSystem (system: let
      inherit (nixpkgs.lib) getName;
      inherit (builtins) elem;
      pkgs = (import nixpkgs) {
        inherit system;
        config.allowUnfreePredicate = pkg: elem (getName pkg) [
          "nrf5-sdk"
        ];
      };
    in rec {
      packages = {
        default = pkgs.callPackage ./package.nix {};
      };
    });
}
