{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "bruno-app";
  version = "v1.35.0";
  src = fetchurl {
    url = "https://github.com/usebruno/bruno/releases/download/${version}/bruno_1.35.0_x86_64_linux.AppImage";
    hash = "sha256-OYtB3aTcPy6LvlE6j1b/CbVUF5SG7bE2uB0nmX4cfOc=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
      install -Dm444 ${appimageContents}/bruno.desktop -t $out/share/applications
      install -Dm444 ${appimageContents}/bruno.png -t $out/share/pixmaps
    '';
}