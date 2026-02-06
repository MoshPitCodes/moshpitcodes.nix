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
    rev = "fb47cb8a47d9b475fafa66b9ff2b3159e296878b";
    hash = "sha256-M/WQFkXb6e2k3k8rNgNThV6BT//neH2iS/cJn+hV7iw=";
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
