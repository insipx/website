{
  rust-bin,
  makeRustPlatform,
  lib,
}:
let

  platform = makeRustPlatform {
    inherit (rust-bin.selectLatestNightlyWith (toolchain: toolchain.minimal)) cargo rustc;
  };
in
platform.buildRustPackage {
  pname = "insipx-website";
  version = "0.1.0";
  src = ./.;
  cargoSha256 = lib.fakeSha256;
}
