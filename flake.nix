{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "ikl";

        meta = {
          name = "ikl-nixos-flake";
          title = "Italik NixOS Flakes";
        };
      };
    };
   in
     lib.mkFlake {
       channels-config = {
         allowUnfree = true;
       };

       systems.modules.nixos = with inputs; [
         impermanence.nixosModules.impermanence
         sops-nix.nixosModules.sops
         disko.nixosModules.disko
       ];
    };
}
