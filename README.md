# materials-flake
A nix flake consisting of various materials modelling programs.

## Packages


| Package                                                     | Description                                                                                            |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [`VESTA`](./pkgs/VESTA)                           | VESTA pre-compiled binary                                                   |
| [`xcrysden`](./pkgs/xcrysden)                           | XCrySDen 1.6.2, manually compiled from source )WIP                                                   |
| [`grace`](./pkgs/grace)                           | Grace 5.1.25, WIP                                                |
| [`fullprof`](./pkgs/fullprof)                           | TBC      

## Usage

Flakes is officially supported and the main method of installation. Your flake `inputs` will look something like this:
```nix
{
  # ...
  inputs = {
    #your other inputs anywhere
    materials = {
       url = "github:chpxu/materials-flake";
       #optional: inputs.nixpkgs.follows = "nixpkgs";
      };
  };
  #...
  outputs = {self, nixpkgs, materials, ...} @ inputs: let 

  inherit (self) outputs; 
  # your other stuff
  in {
    # your configuration
  };
}
```

Then, either inside `home.packages` or `environment.systemPackages`, refer to your flake `inputs`. It may look something like this
```nix
{pkgs, inputs, ...}: {
  home.packages = { #or environment.systemPackages
  # other packages
  inputs.materials.packages.${pkgs.hostPlatform.system}.<package>;

  }; 
}
```
where `<package>` is located in the "Package" column of the table above.