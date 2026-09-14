{
  website,
  buildLayeredImage,
  srv,
  stdenv,
}:
buildLayeredImage {
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
  architecture = if stdenv.hostPlatform.isAarch64 then "arm64" else "amd64";
}
