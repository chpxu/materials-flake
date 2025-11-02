{
  inputs,
  self,
  ...
}: {
  systems = ["x86_64-linux"];

  imports = [inputs.flake-parts.flakeModules.easyOverlay];

  perSystem = {
    config,
    system,
    pkgs,
    ...
  }: let
    pkgs25 = import inputs.nixpkgs-25 {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    overlayAttrs = config.packages;
    packages = {
      VESTA = pkgs.callPackage ./VESTA {inherit inputs pkgs pkgs25;};
    };
  };
}
