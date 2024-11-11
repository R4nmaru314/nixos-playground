{ stdenv, lib, fetchurl, binutils }:

stdenv.mkDerivation rec {
  pname = "outlook-for-linux";
  version = "1.3.13";

  src = fetchurl {
    url = "https://github.com/mahmoudbahaa/outlook-for-linux/releases/download/v1.3.13-outlook/${pname}-${version}.tar.gz";
    sha256 = "sha256-dw619pIEblh5NuvU6zLYpKw9yqB5zmxX+AO7NvzTQVQ=";
  };

  dontBuild = true;

  unpackPhase = ''
    tar -xf $src > $pname
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${pname}-${version} $out/bin/${pname}
    chmod +x $out/bin/${pname}/${pname}
  '';

  meta = with lib; {
    description = "Unofficial Microsoft Outlook client";
    homepage = "https://github.com/mahmoudbahaa/outlook-for-linux";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}