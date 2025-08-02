{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nrf5-sdk";
  version = "15.3.0";

  src = fetchzip {
    url = "https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v15.x.x/nRF5_SDK_${finalAttrs.version}_59ac345.zip";
    hash = "sha256-pfmhbpgVv5x2ju489XcivguwpnofHbgVA7bFUJRTj08=";
  };

  dontConfigure = true;

  buildPhase = ''
    rm -rf examples *.msi
  '';

  installPhase = ''
    mkdir $out
    cp -r * $out/
  '';

  meta = {
    description = "Software development kit for the nRF52 Series and nRF51 Series SoCs";
    homepage = "https://www.nordicsemi.com/Products/Development-software/nrf5-sdk";
    license = lib.licenses.unfree;
    # Just a bunch of c files
    platforms = lib.platforms.all;
  };
})
