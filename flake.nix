{
  description = "A flake for developing and building my personal website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
      crane,
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        common = {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
          ];
        };
        pkgs = import nixpkgs common;
        craneLib = (crane.mkLib pkgs).overrideToolchain (p: p.rust-bin.nightly.latest.minimal);
        crossPkgs = import nixpkgs (
          common
          // {
            crossSystem = "x86_64-unknown-linux-musl";
          }
        );
        crossPkgsAarch64 = import nixpkgs (
          common
          // {
            crossSystem = "aarch64-unknown-linux-musl";
          }
        );
        crossLib-musl64 = (crane.mkLib crossPkgs).overrideToolchain (
          p:
          p.rust-bin.nightly.latest.minimal.override {
            targets = [ "x86_64-unknown-linux-musl" ];
          }
        );
        crossLib-aarch64 = (crane.mkLib crossPkgsAarch64).overrideToolchain (
          p:
          p.rust-bin.nightly.latest.minimal.override {
            targets = [ "aarch64-unknown-linux-musl" ];
          }
        );
      in
      {
        packages = {
          srv-musl64 = crossPkgs.callPackage ./srv { craneLib = crossLib-musl64; };
          srv-aarch64 = crossPkgsAarch64.callPackage ./srv { craneLib = crossLib-aarch64; };
          website = pkgs.callPackage ./site { };
          srv = pkgs.callPackage ./srv { inherit craneLib; };
          image-x86_64 = pkgs.callPackage ./image.nix {
            inherit (self.packages.${system}) website;
            srv = self.packages.${system}.srv-musl64;
          };
          image-aarch64 = pkgs.callPackage ./image.nix {
            inherit (self.packages.${system}) website;
            srv = self.packages.${system}.srv-aarch64;
            architecture = "arm64";
          };
        };
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            zola
            (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))
          ];
        };
      }
    );
}
