{ pkgs, ... }:
{
  # Override Terraform to version 1.14.0
  # nixpkgs-unstable currently provides 1.13.5
  terraform-latest = pkgs.terraform.overrideAttrs (oldAttrs: rec {
    version = "1.14.0";
    src = pkgs.fetchFromGitHub {
      owner = "hashicorp";
      repo = "terraform";
      rev = "v${version}";
      hash = "sha256-nYFw8HWhFCQRVe3ckvwzlO0BUjdkn8rSTCOcqJqCgAI=";
    };
    vendorHash = "sha256-o6To1pZHxcMnKRxJCq+D+L0VkOxdqzKFPfwwVWz2A7E=";
  });
}
