{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/release-23.05";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
  utils.lib.eachDefaultSystem (system: let
      pkgs = (import nixpkgs) {
        inherit system;
        # nrf5-sdk is unfree
        config.allowUnfree = true;
      };
    in rec {
      packages = {
        default = pkgs.callPackage ./package.nix {};
      };
    });
}
