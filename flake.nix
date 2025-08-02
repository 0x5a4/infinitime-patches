{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    {
      nixpkgs,
      utils,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "nrf5-sdk"
              "adafruit-nrfutil"
            ];
        };
      in
      {
        packages = rec {
          nrf5-sdk = pkgs.callPackage ./nrf5-sdk.nix { };
          infinitime = pkgs.callPackage ./infinitime.nix { inherit nrf5-sdk; };
          default = infinitime;
        };
      }
    );
}
