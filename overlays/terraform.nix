final: prev:
let
  version = "1.14.7";
  platformMap = {
    x86_64-linux = {
      arch = "linux_amd64";
      hash = "sha256-6LvO/qgBUVbgTioyXN43oLL7dhcovaVI4v47itfBjJY=";
    };
    aarch64-linux = {
      arch = "linux_arm64";
      hash = "sha256-BPiO6JJNsnwOJsN5chllJzyAybapS8XY2ASKaRY5Uro=";
    };
  };
  platform = platformMap.${prev.stdenv.hostPlatform.system};
in
{
  terraform = prev.stdenvNoCC.mkDerivation {
    pname = "terraform";
    inherit version;

    src = prev.fetchurl {
      url = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${platform.arch}.zip";
      inherit (platform) hash;
    };

    nativeBuildInputs = [ prev.unzip ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 terraform "$out/bin/terraform"
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Tool for building, changing, and versioning infrastructure";
      homepage = "https://www.terraform.io/";
      license = licenses.bsl11;
      mainProgram = "terraform";
      platforms = builtins.attrNames platformMap;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
