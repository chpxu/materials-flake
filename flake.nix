{
  description = "Materials flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-25.url = "github:NixOS/nixpkgs/78e34d1667d32d8a0ffc3eba4591ff256e80576e";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-25,
    ...
  } @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [./pkgs];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
    };
}
