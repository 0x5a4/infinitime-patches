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
          nrf5-sdk = pkgs.callPackage ./pkgs/nrf5-sdk.nix { };
          infinitime = pkgs.callPackage ./pkgs/infinitime.nix { inherit nrf5-sdk; };

          infinitime-patched = infinitime.override {
            userApps = [
              # page 1
              "Apps::StopWatch"
              "Apps::Alarm"
              "Apps::Timer"
              "Apps::Tally"
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
              "Apps::Music"
            ];
            watchFaces = [ "WatchFace::Terminal" ];
            patches = [
              ./patches/fixed-commit-hash.patch
              ./patches/music-redesign-2337.patch
              ./patches/swipe-left-for-music.patch
              ./patches/open-battery-when-charging-1876.patch

              # watch face stuff
              (pkgs.fetchpatch {
                url = "https://patch-diff.githubusercontent.com/raw/InfiniTimeOrg/InfiniTime/pull/2319.patch";
                hash = "sha256-8mrqLlkDsB//ItVpxDRPlfmEhdUv9u41PgbKLFWInPY=";
              })
              ./patches/german-date.patch

              # counter app
              ./patches/tally-2320.patch
            ];
          };

          default = infinitime-patched;
        };
      }
    );
}
