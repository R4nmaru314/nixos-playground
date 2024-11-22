{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "zen-browser";
  version = "1.0.1-a.19";
  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-specific.AppImage";
    hash = "sha256-qAPZ4VyVmeZLRfL0kPHF75zyrSUFHKQUSUcpYKs3jk8=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
}