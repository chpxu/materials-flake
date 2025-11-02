{
  pkgs,
  lib,
  fetchurl ? pkgs.fetchurl,
  gtk3 ? pkgs.gtk3,
  cairo ? pkgs.cairomm,
  libcxx ? pkgs.libcxx,
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
in
  pkgs.stdenv.mkDerivation rec {
    inherit pname src;
    version = "gtk3-x86_64";
    buildInputs = [gtk3 cairo libcxx];
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
      ln -s "$out/share/$pname" "$out/bin/$pname"    '';
    postInstall = ''
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons
      cp ${desktopEntry}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
      ln -s $out/share/$pname/logo@2x.png  $out/share/icons
    '';
    meta = {
      description = "VESTA";
      homepage = "https://jp-minerals.org/vesta/en/";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [chpxu];
      platforms = ["x86_64-linux"];
    };
  }
