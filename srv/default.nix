{
  craneLib,
  pkg-config,
  lib,
  stdenv,
}:
craneLib.buildPackage (
  lib.optionalAttrs stdenv.hostPlatform.isMusl {
    RUSTFLAGS = "-C target-feature=+crt-static";
    doCheck = false;
  }
  // {
    pname = "website-srv";
    src = craneLib.cleanCargoSource ./.;
    version = "0.1.0";
    strictDeps = true;
    nativeBuildInputs = [ pkg-config ];
    CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTarget;
  }
)
