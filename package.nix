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
  fetchFromGitHub,
  fetchpatch,
  adafruit-nrfutil,
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

  src = fetchFromGitHub {
    owner = "InfiniTimeOrg";
    repo = "InfiniTime";
    rev = "1.14.0";
    hash = "sha256-NWqlhQonBhWlSyI4IHLXrc8+FhUKzSo4EvLCLRFgFf0=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      name = "double-click-settings.patch";
      url = "https://github.com/InfiniTimeOrg/InfiniTime/commit/d395f6f0857f082ab3e7fc66cb591b12bbd9cd65.patch";
      sha256 = "sha256-2Jng8JDTU7Zd42qD25CQNeF9dQRSLNwWq9IL+ik0ok0=";
    })
    (fetchpatch {
      name = "casio-weather.patch";
      url = "https://github.com/InfiniTimeOrg/InfiniTime/commit/0206a12ffaecb4d92a3a422e43f4e758d0838f3b.patch";
      sha256 = "sha256-FqyIAgS77z/bO1dcvsmtSK5z/bTRY45S+CaM+PewfvQ=";
    })
    (fetchpatch {
      name = "weather-service-improvements.patch";
      url = "https://github.com/InfiniTimeOrg/InfiniTime/commit/315d679c48503b5f03bdb1b2217e6d64102b2e95.patch";
      sha256 = "sha256-ps9iR0/uiapNG5WK38FU1Pa/2YmZB6KGQQC4M5pkuNA=";
    })
  ];

  nativeBuildInputs = [
    cmake
    lv_img_conv
    nodePackages.lv_font_conv
    python3
    python3.pkgs.cbor
    python3.pkgs.click
    python3.pkgs.cryptography
    python3.pkgs.intelhex
    python3.pkgs.pillow
    adafruit-nrfutil
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
