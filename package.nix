{
  stdenv,
  cmake,
  lv_img_conv,
  nodePackages,
  python3,
  gcc-arm-embedded-10,
  nrf5-sdk,
  fetchzip,
  patch,
  git,
  fetchgit,
}: let
  infinitime-nrf5-sdk = nrf5-sdk.overrideAttrs (old: {
    version = "15.3.0";
    src = fetchzip {
      url = "https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/sdks/nrf5/binaries/nrf5sdk153059ac345.zip";
      sha256 = "sha256-pfmhbpgVv5x2ju489XcivguwpnofHbgVA7bFUJRTj08=";
    };
  });
in stdenv.mkDerivation rec {
  name = "infinitime";

  src = fetchgit {
    url = "https://github.com/InfiniTimeOrg/InfiniTime";
    rev = "1.13.0";
    hash = "sha256-d2zW1JxoQ2j1Yezp3AeDDY7KObyqZ3N8JO4WCbV02sc=";
    deepClone = true;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    lv_img_conv
    nodePackages.lv_font_conv
    python3
    python3.pkgs.cbor
    python3.pkgs.click
    python3.pkgs.cryptography
    python3.pkgs.intelhex
    python3.pkgs.adafruit-nrfutil
    patch
    git
  ];

  postPatch = ''
    # /usr/bin/env is not available in the build sandbox
    substituteInPlace src/displayapp/fonts/generate.py --replace "'/usr/bin/env', 'patch'" "'patch'"
    substituteInPlace tools/mcuboot/imgtool.py --replace "/usr/bin/env python3" "${python3}/bin/python3"
  '';

  cmakeFlags = [
    ''-DARM_NONE_EABI_TOOLCHAIN_PATH=${gcc-arm-embedded-10}''
    ''-DNRF5_SDK_PATH=${infinitime-nrf5-sdk}/share/nRF5_SDK''
    ''-DBUILD_DFU=1''
    ''-DBUILD_RESOURCES=1''
    ''-DCMAKE_SOURCE_DIR=${src}''
  ];

  installPhase = ''
    SOURCES_DIR=${src} BUILD_DIR=. OUTPUT_DIR=$out ./post_build.sh
  '';
}
