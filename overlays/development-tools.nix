{ inputs }:

final: prev: {
  # Infrastructure as Code Tools

  # Terraform 1.14.0
  # Pinned for stability across all hosts
  # Source: https://github.com/hashicorp/terraform/releases/tag/v1.14.0
  terraform = prev.terraform.overrideAttrs (finalAttrs: prevAttrs: {
    version = "1.14.0";
    src = prev.fetchFromGitHub {
      owner = "hashicorp";
      repo = "terraform";
      rev = "v${finalAttrs.version}";
      hash = "sha256-G9GyrwELOuzQqTMimC+z2GJUjq+c5YJDoE313JSsX5w=";
    };
    vendorHash = "sha256-T6baxFk5lrmhyeJgcn7s5cF+utaogSQOD9S5omEKTZg=";

    meta = prevAttrs.meta // {
      changelog = "https://github.com/hashicorp/terraform/releases/tag/v${finalAttrs.version}";
    };
  });

}
