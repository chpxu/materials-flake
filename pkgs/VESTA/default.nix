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
  desktopEntry = pkgs.makeDesktopItem {
    name = pname;
    desktopName = pname;
    exec = "${pname} %f";
    terminal = false;
    icon = "logo@2x";
    categories = ["Science"];
    comment = "VESTA is a 3D visualization program for structural models, volumetric data such as electron/nuclear densities, and crystal morphologies.";
    type = "Application";
  };
  vestaDeriv = pkgs.stdenv.mkDerivation rec {
    inherit pname src;
    version = "gtk3-x86_64";
    buildInputs = [gtk3 gtk2 cairo libcxx] ++ (with pkgs; [libGLU curl]);
    nativeBuildInputs = [
      pkgs.xorg.libXtst
      pkgs.xorg.libXxf86vm
      pkgs.javaPackages.compiler.openjdk11-bootstrap
      autoPatchelfHook
      pkg-config
      pkgs25.webkitgtk_4_0
    ];

    unpackPhase = ''
      tar -xjf $src
    '';
    installPhase = ''
      mkdir -p $out/{bin,share}
      mkdir -p $out/share/$pname
      # VESTA is downloaded with the executable
      # and all the other files needed, so we don't want
      # to lose any of them
      cp -r "${pname}-${version}"/* "$out/share/$pname"
      ln -s "$out/share/$pname/$pname" "$out/bin/$pname"
      ln -s "$out/share/$pname/$pname-gui" "$out/bin/$pname-gui"
      #install -m755 -D VESTA $out/bin/VESTA
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons

      install -m 444 -D ${desktopEntry}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
      ln -s $out/share/$pname/img/logo@2x.png  $out/share/icons
    '';
  };
in
  pkgs.buildFHSEnv {
    name = pname;
    targetPkgs = pkgs:
      with pkgs; [
        vestaDeriv
        gtk3
        gtk2
        cairo
        libcxx
      ];
    runScript = "VESTA";

    meta = {
      description = "VESTA";
      homepage = "https://jp-minerals.org/vesta/en/";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [chpxu];
      platforms = ["x86_64-linux"];
    };
  }
