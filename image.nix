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
    "--port"
    "8080"
  ];
  contents = [
    srv
    website
  ];
  inherit architecture;
}
