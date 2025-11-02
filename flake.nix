{
  description = "Materials flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [./pkgs];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
    };
}
