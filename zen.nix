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

  extraInstallCommands = ''
      mv $out/bin/{${pname},zen}
      install -Dm444 ${appimageContents}/zen.desktop -t $out/share/applications
      install -Dm444 ${appimageContents}/zen.png -t $out/share/pixmaps
    '';

  meta = {
    description = "Fork of Firefox, focused on privacy, security and freedom (upstream AppImage release)";
    homepage = "https://zen-browser.app/";
    license = lib.licenses.mpl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "zen";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}