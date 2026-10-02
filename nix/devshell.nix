{
  flake,
  perSystem,
  pkgs,
  ...
}:
pkgs.mkShell {
  packages = with pkgs; [
    # keep-sorted start
    bun
    cocogitto
    copier
    git
    git-credential-oauth
    lazygit
    nil
    nixd
    perSystem.self.capa
    repgrep
    ripgrep
    uv
    # keep-sorted end
  ];
  shellHook = ''
    ${flake.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check.shellHook}
    capa install --yes || echo "capa: install skipped (offline?)"
  '';
}
