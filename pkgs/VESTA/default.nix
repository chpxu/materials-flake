{
  inputs,
  pkgs,
  pkgs25,
  lib,
  fetchurl ? pkgs.fetchurl,
  gtk3 ? pkgs.gtk3,
  gtk2 ? pkgs.gtk2,
  cairo ? pkgs.cairomm,
  libcxx ? pkgs.libcxx,
  autoPatchelfHook,
  pkg-config,
  ...
}: let
  url = "https://jp-minerals.org/vesta/archives/testing/VESTA-gtk3-x86_64.tar.bz2";
  pname = "VESTA";
  src = fetchurl {
    inherit url;
    sha256 = "sha256-WvO+Rc0Z1LYBudPhkNOf2M9m8BPgEkIIOYR7tFGaM6Y=";
  };

  vestaDeriv = pkgs.stdenv.mkDerivation rec {
    inherit pname src;
    version = "gtk3-x86_64";
    buildInputs = [gtk3 gtk2 cairo libcxx];
    nativeBuildInputs = [
      pkgs.xorg.libXtst
      pkgs.xorg.libXxf86vm
      pkgs.javaPackages.compiler.openjdk11-bootstrap # libjawt.so
      pkgs.libGLU
      pkgs.libGL
      pkgs.curl
      pkgs.libxcb-wm
      autoPatchelfHook
      pkg-config
      pkgs25.webkitgtk_4_0
      pkgs.libglvnd
      pkgs.mesa.drivers
    ];
    LD_LIBRARY_PATH = with pkgs;
      lib.makeLibraryPath [
        libGL
        xorg.libXrandr
        xorg.libXinerama
        xorg.libXcursor
        xorg.libXi
        xorg.libX11
        libGLU
        libglvnd
      ];

    unpackPhase = ''
      tar -xjf $src
    '';
    installPhase = ''
      mkdir -p $out/{bin,share}
      mkdir -p $out/share/applications
      mkdir -p $out/share/applications/$pname
      mkdir -p $out/share/icons
      # VESTA is downloaded with the executable
      # and all the other files needed, so we don't want
      # to lose any of them
      cp -r "${pname}-${version}"/* "$out/share/applications/$pname"
      ln -s "$out/share/applications/$pname/$pname" "$out/bin/$pname"
      ln -s "$out/share/applications/$pname/${pname}-gui" "$out/bin/${pname}-gui"
      #install -m755 -D VESTA $out/bin/VESTA

      # install -m 444 -D desktopEntry/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
      # cp desktopEntry/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
      # ln -s $out/share/applications/$pname/img/logo@2x.png  $out/share/icons
    '';
    # postFixup = ''
    #   patchelf \
    #     --add-needed ${pkgs.libGL}/lib/libGL.so.1 \
    #     $out/share/applications/$pname/VESTA-gui
    # '';
  };
in
  pkgs.buildFHSEnv rec {
    name = pname;
    targetPkgs = pkgs:
      with pkgs; [
        vestaDeriv
        gtk3
        gtk2
        cairo
        libcxx
        libGL
        libGLU
      ];
    runScript = "${vestaDeriv}/share/applications/VESTA/VESTA-gui";
    wrappedVesta = pkgs.writeShellScriptBin "VESTA" ''
      export LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib:$LD_LIBRARY_PATH"
      cd ${vestaDeriv}/share/applications/VESTA/
      exec ./VESTA-gui "$@"
    '';
    desktopEntry = pkgs.makeDesktopItem {
      name = pname;
      desktopName = pname;
      exec = "VESTA";
      terminal = true;
      icon = "${vestaDeriv}/share/applications/VESTA/img/logo@2x";
      categories = ["Science"];
      comment = "VESTA is a 3D visualization program for structural models, volumetric data such as electron/nuclear densities, and crystal morphologies.";
      type = "Application";
    };
    meta = {
      description = "VESTA";
      homepage = "https://jp-minerals.org/vesta/en/";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [chpxu];
      platforms = ["x86_64-linux"];
    };
  }
