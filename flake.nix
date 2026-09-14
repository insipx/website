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
        crossPkgs = import nixpkgs (
          common
          // {
            crossSystem = "x86_64-unknown-linux-musl";
          }
        );
        craneLib = (crane.mkLib pkgs).overrideToolchain (p: p.rust-bin.nightly.latest.minimal);
        crossLib = (crane.mkLib crossPkgs).overrideToolchain (
          p:
          p.rust-bin.nightly.latest.minimal.override {
            targets = [ "x86_64-unknown-linux-musl" ];
          }
        );
      in
      {
        packages = {
          srv-musl64 = crossPkgs.callPackage ./srv { craneLib = crossLib; };
          website = pkgs.callPackage ./site { };
          srv = pkgs.callPackage ./srv { inherit craneLib; };
          image =
            let
              srv = self.packages.${system}.srv-musl64;
              inherit (self.packages.${system}) website;
            in
            pkgs.dockerTools.buildLayeredImage {
              name = "ghcr.io/insipx/website";
              tag = "main";
              created = "now";
              config.Entrypoint = [
                "website-srv"
                "--directory"
                "${website}"
              ];
              contents = [
                srv
                website
              ];
              architecture = "amd64";
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
