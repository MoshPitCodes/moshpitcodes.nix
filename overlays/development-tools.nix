{ inputs ? null }:

_final: prev: {
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

  # OpenCode v1.1.41 (latest)
  # AI coding agent built for the terminal
  # Source: https://github.com/sst/opencode/releases/tag/v1.1.41
  opencode = prev.opencode.overrideAttrs (finalAttrs: prevAttrs: {
    version = "1.1.41";
    src = prev.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${finalAttrs.version}";
      hash = "sha256-p4mZRJ+BQs790hjCOJ9iXzg3JoCa4lqOdCqDRkoEfWw=";
    };

    node_modules = prevAttrs.node_modules.overrideAttrs {
      inherit (finalAttrs) version src;
      outputHash = "sha256-bjSPHxPTyzhMOztd7HjUl/lvMZYVk944xPj8ADDn5Y4=";
    };

    env = (prevAttrs.env or {}) // {
      OPENCODE_VERSION = finalAttrs.version;
    };

    meta = prevAttrs.meta // {
      changelog = "https://github.com/sst/opencode/releases/tag/v${finalAttrs.version}";
    };
  });

  # Claude Code v2.1.23 (latest)
  # Agentic coding tool from Anthropic
  # Source: https://github.com/anthropics/claude-code/releases/tag/v2.1.23
  claude-code = prev.claude-code.overrideAttrs (finalAttrs: prevAttrs: {
    version = "2.1.23";

    src = prev.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
      hash = "sha256-Cl/lwk1ffwrc+v1ncdShjeheNnkoocmXSDUDOCRHJgQ=";
    };

    meta = prevAttrs.meta // {
      changelog = "https://github.com/anthropics/claude-code/releases/tag/v${finalAttrs.version}";
    };
  });

}
