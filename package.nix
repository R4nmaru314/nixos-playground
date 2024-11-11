{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  alsa-utils,
  copyDesktopItems,
  electron_32,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  which,
}:

buildNpmPackage rec {
  pname = "outlook-for-linux";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "r4nmaru314";
    repo = "outlook-for-linux";
    rev = "refs/tags/v${version}";
    hash = "sha256-VHII/14og3yHwiovQLnfYHZ/fmqDsZDsmW1J1ICieIg=";
  };

  npmDepsHash = "sha256-7P9MWR4a5wRwutKx4gx3SmyOz7G974G+CE9qfrhlTkw=";

  nativeBuildInputs = [
    makeWrapper
  ] ++ lib.optionals (stdenv.hostPlatform.isLinux) [ copyDesktopItems ];

  doInstallCheck = stdenv.hostPlatform.isLinux;

  env = {
    # disable code signing on Darwin
    CSC_IDENTITY_AUTO_DISCOVERY = "false";
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };

  buildPhase = ''
    runHook preBuild

    cp -r ${electron_32.dist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
        --dir \
        -c.npmRebuild=true \
        -c.asarUnpack="**/*.node" \
        -c.electronDist=electron-dist \
        -c.electronVersion=${electron_32.version}

    runHook postBuild
  '';

  installPhase =
    ''
      runHook preInstall

    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p $out/share/{applications,outlook-for-linux}
      cp dist/*-unpacked/resources/app.asar $out/share/outlook-for-linux/

      pushd build/icons
      for image in *png; do
        mkdir -p $out/share/icons/hicolor/''${image%.png}/apps
        cp -r $image $out/share/icons/hicolor/''${image%.png}/apps/outlook-for-linux.png
      done
      popd

      # Linux needs 'aplay' for notification sounds
      makeWrapper '${lib.getExe electron_32}' "$out/bin/outlook-for-linux" \
        --prefix PATH : ${
          lib.makeBinPath [
            alsa-utils
            which
          ]
        } \
        --add-flags "$out/share/outlook-for-linux/app.asar" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      cp -r dist/mac*/outlook-for-linux.app $out/Applications
      makeWrapper $out/Applications/outlook-for-linux.app/Contents/MacOS/outlook-for-linux $out/bin/outlook-for-linux
    ''
    + ''

      runHook postInstall
    '';

  desktopItems = [
    (makeDesktopItem {
      name = "outlook-for-linux";
      exec = "outlook-for-linux";
      icon = "outlook-for-linux";
      desktopName = "Microsoft Outlook for Linux";
      comment = meta.description;
      categories = [
        "Network"
        "InstantMessaging"
        "Chat"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial Microsoft Outlook client for Linux";
    mainProgram = "outlook-for-linux";
    homepage = "https://github.com/mahmoudbahaa/outlook-for-linux";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      r4nmaru
    ];
    platforms = with lib.platforms; darwin ++ linux;
  };
}