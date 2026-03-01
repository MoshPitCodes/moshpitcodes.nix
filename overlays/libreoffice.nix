# Workaround for nixpkgs bug: NotoSansArabic[wdth,wght].ttf variable font
# filename contains '[' which breaks the cp glob in the noto-fonts-subset
# runCommand inside the LibreOffice derivation.
#
# The broken buildCommand in nixpkgs libreoffice/default.nix is:
#   cp "${noto-fonts}/share/fonts/noto/NotoSansArabic["*.[ot]tf "$out/share/fonts/noto/"
# The '[' in the Nix string literal terminates the shell-quoted string early,
# causing cp to fail with "missing destination file operand".
#
# Fix: override libreoffice-still.unwrapped to replace FONTCONFIG_FILE with a
# reconstructed makeFontsConf that uses a find-based noto-fonts-subset instead.
#
# TODO: Remove when upstream nixpkgs fixes the quoting bug.
# Upstream issue: https://github.com/NixOS/nixpkgs/issues/395540
{ inputs }:
final: prev:
let
  # Fixed noto-fonts-subset: uses find to copy Arabic fonts, correctly handling
  # filenames that contain '[' (variable font axis notation).
  fixed-noto-fonts-subset = prev.runCommand "noto-fonts-subset" { } ''
    mkdir -p "$out/share/fonts/noto/"
    find "${prev.noto-fonts}/share/fonts/noto" -maxdepth 1 \
      \( -name "NotoSansArabic*.ttf" -o -name "NotoSansArabic*.otf" \) \
      -exec cp {} "$out/share/fonts/noto/" \;
  '';

  # Reconstruct the fonts config with the fixed noto-fonts-subset.
  # Mirrors the fontsConf font list from nixpkgs libreoffice/default.nix (still variant).
  fixed-fonts-conf = prev.makeFontsConf {
    fontDirectories = [
      prev.amiri
      prev.caladea
      prev.carlito
      prev.culmus
      prev.dejavu_fonts
      prev.rubik
      prev.liberation-sans-narrow
      prev.liberation_ttf_v2
      prev.libertine
      prev.libertine-g
      prev.noto-fonts-lgc-plus
      fixed-noto-fonts-subset
      prev.noto-fonts-cjk-sans
    ];
  };

  fixed-libreoffice-still-unwrapped = prev.libreoffice-still.unwrapped.overrideAttrs (old: {
    env = (old.env or { }) // {
      FONTCONFIG_FILE = fixed-fonts-conf;
    };
  });

  fixed-libreoffice-still = prev.libreoffice-still.override {
    unwrapped = fixed-libreoffice-still-unwrapped;
  };
in
{
  libreoffice-still = fixed-libreoffice-still;
  libreoffice = prev.lib.hiPrio fixed-libreoffice-still;
}
