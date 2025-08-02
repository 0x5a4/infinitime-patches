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

          infinitime-patched = infinitime.override {
            userApps = [
              # page 1
              "Apps::StopWatch"
              "Apps::Alarm"
              "Apps::Timer"
              "Apps::Music"
              "Apps::Steps"
              "Apps::Weather"
              # page 2
              "Apps::HeartRate"
              "Apps::Paint"
              "Apps::Paddle"
              "Apps::Twos"
              "Apps::Dice"
              "Apps::Navigation"
              # page 3
              "Apps::Metronome"
            ];
            watchFaces = [ "WatchFace::Terminal" ];
            patches = [
              ./patches/fixed-commit-hash.patch
              ./patches/music-redesign-2337.patch
              ./patches/swipe-left-for-music.patch

              (pkgs.fetchpatch {
                url = "https://patch-diff.githubusercontent.com/raw/InfiniTimeOrg/InfiniTime/pull/2319.patch";
                hash = "sha256-8mrqLlkDsB//ItVpxDRPlfmEhdUv9u41PgbKLFWInPY=";
              })
            ];
          };

          default = infinitime-patched;
        };
      }
    );
}
