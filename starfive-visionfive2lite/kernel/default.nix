# Mainline Linux for the VisionFive 2 Lite (JH7110S): its device trees landed in 6.19.
# On its own pinned nixpkgs, so updates never rebuild it; cross-compiled on tron and
# published to /kernels, the board only downloads it.
{
  buildSystem ? "riscv64-linux",
}:

let
  nixpkgsSrc = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "885ba4d038f10c3d17d7a92e8c3cc185b99c9158";
    shallow = true;
  };
  pkgs =
    if buildSystem == "riscv64-linux" then
      import nixpkgsSrc { system = "riscv64-linux"; }
    else
      import nixpkgsSrc {
        localSystem = buildSystem;
        crossSystem = "riscv64-linux";
      };
in
{
  inherit pkgs;
  kernel = pkgs.linuxPackages_7_3.kernel;
}
