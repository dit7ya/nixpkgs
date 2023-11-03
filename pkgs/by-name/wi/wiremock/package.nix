{ lib, stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "wiremock";
  version = "3.2.0";

  src = fetchurl {
    url = "mirror://maven/org/wiremock/wiremock-standalone/${version}/wiremock-standalone-${version}.jar";
    hash = "sha256-voO9UAxhxQlWWs4jMji93TBUCcFWht/4Cea+UpBmL3Q=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out"/{share/wiremock,bin}
    cp ${src} "$out/share/wiremock/wiremock.jar"

    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/wiremock/wiremock.jar"
  '';

  meta = {
    description = "A flexible tool for building mock APIs";
    homepage = "https://wiremock.org/";
    changelog = "https://github.com/wiremock/wiremock/releases/tag/${version}";
    maintainers = with lib.maintainers; [ bobvanderlinden anthonyroussel ];
    mainProgram = "wiremock";
    platforms = jre.meta.platforms;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.asl20;
  };
}
