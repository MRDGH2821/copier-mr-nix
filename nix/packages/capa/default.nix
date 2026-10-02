# Hashes: https://github.com/infragate/capa/releases/download/v<version>/SHA256SUMS.txt
{pkgs, ...}: let
  version = "2.2.4";
  assets = {
    aarch64-darwin = {
      sha256 = "9b7a7ce61eb732e82954e13c8f4dfc738f9643765020b3c713228372a688f70b";
      suffix = "aarch64-apple-darwin";
    };
    aarch64-linux = {
      sha256 = "ea1bd097bda37510cacbf71dec45780e299540648143d1b9ab82d1ecba2b937b";
      suffix = "aarch64-unknown-linux-gnu";
    };
    x86_64-darwin = {
      sha256 = "3560f27354fb3e4599de73d3dba7af46797a8b0b5ddfab028217c4bde5a502bb";
      suffix = "x86_64-apple-darwin";
    };
    x86_64-linux = {
      sha256 = "d7fb0dfd2ae65c6edc73968d4f6ccc6578d96946d1eea0cd0ab962bd4114ae87";
      suffix = "x86_64-unknown-linux-gnu";
    };
  };
  asset =
    assets.${pkgs.stdenv.hostPlatform.system}
      or (throw "capa: unsupported system ${pkgs.stdenv.hostPlatform.system}");
in
  pkgs.stdenvNoCC.mkDerivation {
    inherit version;
    dontUnpack = true;
    installPhase = ''
      install -Dm755 $src $out/bin/capa
    '';
    meta = {
      description = "Agentic skills and tools package manager";
      homepage = "https://github.com/infragate/capa";
      mainProgram = "capa";
    };
    pname = "capa";
    src = pkgs.fetchurl {
      inherit (asset) sha256;
      url = "https://github.com/infragate/capa/releases/download/v${version}/capa-${asset.suffix}";
    };
  }
