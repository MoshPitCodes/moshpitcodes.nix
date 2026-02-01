{
  inputs ? null,
}:

_final: prev: {
  # Infrastructure as Code Tools

  # Terraform 1.14.4
  # Pinned for stability across all hosts
  # Source: https://github.com/hashicorp/terraform/releases/tag/v1.14.4
  terraform = prev.terraform.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "1.14.4";
      src = prev.fetchFromGitHub {
        owner = "hashicorp";
        repo = "terraform";
        rev = "v${finalAttrs.version}";
        hash = "sha256-fEuIAKmR+shKHNldUlU6qvel9tjYFdKnc25JWtxRPHs=";
      };
      vendorHash = "sha256-NDtBLa8vokrSRDCNX10lQyfMDzTrodoEj5zbDanL4bk=";

      meta = prevAttrs.meta // {
        changelog = "https://github.com/hashicorp/terraform/releases/tag/v${finalAttrs.version}";
      };
    }
  );

  # OpenCode v1.1.42 (latest)
  # AI coding agent built for the terminal
  # Source: https://github.com/sst/opencode/releases/tag/v1.1.42
  opencode = prev.opencode.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "1.1.42";
      src = prev.fetchFromGitHub {
        owner = "sst";
        repo = "opencode";
        tag = "v${finalAttrs.version}";
        hash = "sha256-zLOnLuMzoyR/jBDKi3qxN6gId5KgI+MrTPjX21g7X2o=";
      };

      node_modules = prevAttrs.node_modules.overrideAttrs {
        inherit (finalAttrs) version src;
        outputHash = "sha256-bjSPHxPTyzhMOztd7HjUl/lvMZYVk944xPj8ADDn5Y4=";
      };

      env = (prevAttrs.env or { }) // {
        OPENCODE_VERSION = finalAttrs.version;
      };

      meta = prevAttrs.meta // {
        changelog = "https://github.com/sst/opencode/releases/tag/v${finalAttrs.version}";
      };
    }
  );

  # Claude Code v2.1.23 (latest)
  # Agentic coding tool from Anthropic
  # Source: https://github.com/anthropics/claude-code/releases/tag/v2.1.23
  claude-code = prev.claude-code.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "2.1.23";

      src = prev.fetchzip {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
        hash = "sha256-Cl/lwk1ffwrc+v1ncdShjeheNnkoocmXSDUDOCRHJgQ=";
      };

      meta = prevAttrs.meta // {
        changelog = "https://github.com/anthropics/claude-code/releases/tag/v${finalAttrs.version}";
      };
    }
  );

  # Gradle 9.3.1
  # Pinned for stability across all hosts
  # Source: https://github.com/gradle/gradle/releases/tag/v9.3.1
  gradle_9 = prev.gradle_9.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "9.3.1";
      src = prev.fetchurl {
        url = "https://services.gradle.org/distributions/gradle-${finalAttrs.version}-bin.zip";
        hash = "sha256-smbV/2uQ6tptw7IMsJDjcxMC5VOifF0+TfHw12vq/wY=";
      };

      meta = prevAttrs.meta // {
        changelog = "https://github.com/gradle/gradle/releases/tag/v${finalAttrs.version}";
      };
    }
  );

  # RepoSync - Repository synchronization TUI
  # Modern CLI tool for repository synchronization with interactive TUI
  # Source: https://github.com/moshpitcodes/reposync
  reposync = prev.callPackage ../pkgs/reposync/default.nix { };

}
