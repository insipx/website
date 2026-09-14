{
  stdenv,
  zola,
  cacert,
}:
stdenv.mkDerivation {
  pname = "website";
  version = "2026-09-12";
  src = ./.;
  nativeBuildInputs = [
    zola
    cacert
  ];
  # preBuild = ''
  #   cp ${resume.packages.${system}.default}/resume.pdf static/resume.pdf
  # '';
  buildPhase = "zola build";
  installPhase = "cp -r public $out";

}
