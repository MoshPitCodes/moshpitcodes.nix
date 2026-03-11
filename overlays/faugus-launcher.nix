{ }:
final: prev: {
  faugus-launcher = prev.faugus-launcher.overrideAttrs (old: rec {
    version = "1.16.2";
    src = prev.fetchFromGitHub {
      owner = "Faugus";
      repo = "faugus-launcher";
      rev = version;
      hash = "sha256-ikTVvCsCRk+HZYoUUGf+e78mciv0aga8oxxn7k3tOHg=";
    };
  });
}
