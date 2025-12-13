{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  makeWrapper,
}:

buildGoModule rec {
  pname = "reposync";
  version = "unstable-2024-12-13";

  src = fetchFromGitHub {
    owner = "moshpitcodes";
    repo = "reposync";
    rev = "main";
    hash = "sha256-KOQSpFHvog/0q53z0hXuspUI4SR/Evg+fCzQjMrJS9Q=";
  };

  vendorHash = "sha256-OMmNgun7bbutlfs3g5zXfykDQUIA8TAfaVhYfprtK2w=";

  nativeBuildInputs = [ makeWrapper ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.builtBy=nix"
  ];

  # Wrap with git only; gh is optional (user installs separately if needed)
  postInstall = ''
    wrapProgram $out/bin/reposync \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  meta = with lib; {
    description = "Modern CLI tool for repository synchronization with interactive TUI";
    homepage = "https://github.com/moshpitcodes/reposync";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "reposync";
  };
}
