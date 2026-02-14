{ }:

_final: prev: {
  # Infrastructure as Code Tools

  # Terraform 1.14.5
  # Pinned for stability across all hosts
  # Source: https://github.com/hashicorp/terraform/releases/tag/v1.14.5
  terraform = prev.terraform.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "1.14.5";
      src = prev.fetchFromGitHub {
        owner = "hashicorp";
        repo = "terraform";
        rev = "v${finalAttrs.version}";
        hash = "sha256-qy/aS82YLIalVDFje4F7TWzC8OdYGBijuEpbDMlyEKY=";
      };
      vendorHash = "sha256-NDtBLa8vokrSRDCNX10lQyfMDzTrodoEj5zbDanL4bk=";

      meta = prevAttrs.meta // {
        changelog = "https://github.com/hashicorp/terraform/releases/tag/v${finalAttrs.version}";
      };
    }
  );

  # OpenCode v1.2.1 (latest)
  # AI coding agent built for the terminal
  # Source: https://github.com/sst/opencode/releases/tag/v1.2.1
  opencode = prev.opencode.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "1.2.1";
      src = prev.fetchFromGitHub {
        owner = "sst";
        repo = "opencode";
        tag = "v${finalAttrs.version}";
        hash = "sha256-/D0tn09kC1AClJI3uFzMMWBvVWMYvvw52YrRD+dw0D4=";
      };

      node_modules = prevAttrs.node_modules.overrideAttrs {
        inherit (finalAttrs) version src;
        outputHash = "sha256-2zl08cUvIGwK843o+7NcPBOscoSasXzYNLy30htgvYE=";
      };

      env = (prevAttrs.env or { }) // {
        OPENCODE_VERSION = finalAttrs.version;
      };

      meta = prevAttrs.meta // {
        changelog = "https://github.com/sst/opencode/releases/tag/v${finalAttrs.version}";
      };
    }
  );

  # Claude Code v2.1.39 (latest)
  # Agentic coding tool from Anthropic
  # Source: https://github.com/anthropics/claude-code/releases/tag/v2.1.39
  claude-code = prev.claude-code.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "2.1.39";

      src = prev.fetchzip {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
        hash = "sha256-NLLiaJkU91ZnEcQUWIAX9oUTt+C5fnWXFFPelTtWmdo=";
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
