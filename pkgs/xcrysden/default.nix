{
  pkgs,
  lib,
  fetchurl ? pkgs.fetchurl,
  gcc ? pkgs.gcc,
  gfortran15 ? pkgs.gfortran15,
  tcl ? pkgs.tcl,
  tk ? pkgs.tclPackages.tk,
  fftw ? pkgs.fftw,
  libcxx ? pkgs.libcxx,
  x11 ? pkgs.xorg.libX11,
  gnumake ? pkgs.gnumake,
  autoPatchelfHook,
  pkg-config,
  ...
}: let
  version = "1.6.2";
  url = "http://www.xcrysden.org/download/xcrysden-${version}.tar.gz";
  pname = "xcrysden";
  xcrysden-src = fetchurl {
    inherit url;
    name = "xcrysden";
    sha256 = "sha256-gRc27lmL7BpbQn/RDk4GOjDdfK2ulqQ6ULNs6QpPUD8=";
  };

  bwidget = fetchurl {
    url = "http://sourceforge.net/projects/tcllib/files/BWidget/1.9.13/bwidget-1.9.13.tar.gz";
    sha256 = "sha256-dtj0IoDnFgJCGG0SQ3lJgw6r1QCabBT059ug9mFAOoE=";
  };
  togl2 = fetchurl {
    url = "https://sourceforge.net/projects/togl/files/Togl/2.0/Togl2.0-8.4-Linux64.tar.gz";
    sha256 = "sha256-37FpRkmFmKmRh6JD+PIGioWCQ8Px3eiKLT8NtdGz6R0=";
  };
in
  pkgs.stdenv.mkDerivation rec {
    inherit pname version;
    srcs = [xcrysden-src bwidget togl2];
    buildInputs = [tcl tk fftw libcxx x11 pkgs.tclPackages.bwidget gcc gfortran15 gnumake pkgs.wget];
    nativeBuildInputs =
      buildInputs
      ++ [
        autoPatchelfHook
        pkgs.libGL
        pkgs.libGLU
        pkgs.libxmu
      ];
    unpackPhase = ''
      arr=($srcs)
       tar -xvf ''${arr[0]}
       cp -r ''${arr[1]} "${pname}-${version}/external/src/bwidget-1.9.13.tar.gz"
       mkdir togl
       tar -xvf ''${arr[2]} -C togl --strip-components=1
       #cp -r "togl/include"/* "${pname}-${version}/C/"

    '';
    sourceRoot = "${pname}-${version}";
    buildPhase = ''
      mkdir -p $out/{bin,share}
      mkdir -p $out/share/applications
      mkdir -p $out/share/applications/$pname
      mkdir -p $out/share/icons
      # cp ${pname}-${version}/system/Make.sys-shared Make.sys
      ls external/src
      ls C
      export C_INCLUDE_PATH="../togl/include:$C_INCLUDE_PATH"
      #cd ${pname}-${version}
      cp ./system/Make.sys-shared Make.sys
      # Compilation autodownloads BWidget. We do it ahead-of-time instead, so don't do it!
      #sed -i '289d' ./external/src/Makefile
      #sed -i -e 's/#include <togl.h>/#include \"togl.h\"/g' C/xcAppInit.c
      make all

    '';
    meta = {
      description = "XCrySDen";
      homepage = "https://jp-minerals.org/vesta/en/";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [chpxu];
      platforms = ["x86_64-linux"];
    };
  }
