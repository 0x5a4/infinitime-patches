{
  lib,
  stdenv,
  cmake,
  ninja,
  gcc-arm-embedded-10,
  lv_font_conv,
  adafruit-nrfutil,
  nrf5-sdk,
  python3,
  fetchFromGitHub,
  buildResources ? true,
  buildDfu ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "infinitime";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "InfiniTimeOrg";
    repo = "InfiniTime";
    rev = finalAttrs.version;
    hash = "sha256-FLXMaXqn+SOPC+ft7Ee3Gf7mUnb76dcZcJrXbUDOnZ0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs =
    [
      cmake
      ninja
      gcc-arm-embedded-10
      python3
      python3.pkgs.cbor
      python3.pkgs.click
      python3.pkgs.cryptography
      python3.pkgs.intelhex
      python3.pkgs.pillow
    ]
    ++ lib.optionals buildResources [ lv_font_conv ]
    ++ lib.optional buildDfu [ adafruit-nrfutil ];

  postPatch = ''
    sed -i "s-'/usr/bin/env',--" ./src/displayapp/fonts/generate.py
    sed -i "s-'/usr/bin/env',--" ./src/resources/generate-fonts.py
    patchShebangs ./tools/mcuboot/imgtool.py
  '';

  dontFixCmake = true;

  cmakeFlags =
    [
      "-DARM_NONE_EABI_TOOLCHAIN_PATH=${gcc-arm-embedded-10}"
      "-DNRF5_SDK_PATH=${nrf5-sdk}"
    ]
    ++ lib.optional buildResources "-DBUILD_RESOURCES=1"
    ++ lib.optional buildDfu "-DBUILD_DFU=1";

  installPhase =
    ''
      mkdir $out
      cp src/pinetime-* $out
    ''
    + lib.optionalString buildResources "cp src/resources/*.zip $out";

  dontPatchELF = true;
  noAuditTmpdir = true;

  meta = {
    description = "Fast open-source firmware for the PineTime smartwatch with many features, written in modern C++";
    homepage = "https://github.com/InfiniTimeOrg/InfiniTime";
    license = lib.licenses.gpl3Plus;
  };
})
