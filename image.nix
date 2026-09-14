{
  website,
  srv,
  dockerTools,
  architecture ? "amd64",
}:
dockerTools.buildLayeredImage {
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
  inherit architecture;
}
