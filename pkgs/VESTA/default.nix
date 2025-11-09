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
in
  pkgs.stdenv.mkDerivation rec {
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
        glfw
        libdrm
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
      cp -r "${pname}-${version}"/* "$out/bin"
      cat <<INI > $out/share/applications/${pname}.desktop
      [Desktop Entry]
      Terminal=false
      Name=${pname}
      Exec=$out/bin/${pname} %f
      Type=Application
      icon = "$out/bin/img/logo@2x.png"
      categories = ["Science"]
      comment = "VESTA is a 3D visualization program for structural models, volumetric data such as electron/nuclear densities, and crystal morphologies."
      INI
    '';
    meta = {
      description = "VESTA";
      homepage = "https://jp-minerals.org/vesta/en/";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [chpxu];
      platforms = ["x86_64-linux"];
    };
  }
