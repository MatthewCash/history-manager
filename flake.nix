{
    description = "History Manager Firefox Addon";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = inputs @ { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = nixpkgs.legacyPackages.${system};
            nodejs = pkgs.nodejs-16_x;
            nodeEnv = import ./node-env.nix {
                inherit (pkgs) stdenv lib python2 runCommand writeTextFile writeShellScript;
                inherit pkgs nodejs;
                libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
            };
            nodePackage = import ./node-packages.nix {
                inherit (pkgs) fetchurl nix-gitignore stdenv lib fetchgit;
                inherit nodeEnv;
            };
        in {
            devShell = nodePackage.shell;
            defaultPackage = pkgs.stdenvNoCC.mkDerivation {
                name = "history-manager";
                src = "${nodePackage.package}/lib/node_modules/history-manager";
                dontConfigure = true;
                buildPhase = ''
                    shopt -s globstar
                    shopt -s nullglob
                    
                    for i in ./src/**/*.ts; do
                        ${pkgs.esbuild}/bin/esbuild "$i" --bundle --minify --sourcemap --target=firefox102 --outdir=./build/$(dirname "''${i#./*/}")
                    done

                    cp -r assets/* build/
                    cd build
                    ${pkgs.zip}/bin/zip -r history-manager.xpi *
                '';
                installPhase = ''
                    mkdir -p $out/addon
                    cp history-manager.xpi $out/addon/
                '';
            };
        }
    );
}
