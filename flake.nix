{
    description = "History Manager Firefox Addon";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = nixpkgs.legacyPackages.${system};
            nodejs = pkgs.nodejs;
            nodeEnv = import ./node-env.nix {
                inherit (pkgs) stdenv lib python2 runCommand writeTextFile writeShellScript;
                inherit pkgs nodejs;
                libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
            };
            nodePackage = import ./node-packages.nix {
                inherit (pkgs) fetchurl nix-gitignore stdenv lib fetchgit;
                inherit nodeEnv;
            };
            npm = "${nodejs}/bin/npm";
        in {
            devShell = nodePackage.shell;
            defaultPackage = pkgs.stdenvNoCC.mkDerivation {
                name = "history-manager";
                src = "${nodePackage.package}/lib/node_modules/history-manager";
                dontConfigure = true;
                buildPhase = ''
                    ${npm} run build:firefox
                    ${npm} run pack
                '';
                checkPhase = ''
                    ${npm} run test
                '';
                installPhase = ''
                    mkdir -p $out/addon
                    cp ext-out/* $out/addon/
                '';
            };
        }
    );
}
