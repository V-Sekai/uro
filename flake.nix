{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});

    packageFor = pkgs: rec {
      uro = pkgs.callPackage ./nix {};
      default = uro;
    };
  in 
    {
      packages = forAllSystems (system:
        let packages = packageFor pkgs.${system}; in
        packages // { default = packages.default; });

      overlay = final: prev: packageFor final;
    };
}
