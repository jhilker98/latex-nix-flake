{
  description = "LaTeX Document Demo";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    systems.url = github:nix-systems/x86_64-linux;
    utils = {
      url = github:numtide/flake-utils;
      inputs.systems.follows = "systems";
    };
  };
  outputs = { self, nixpkgs, utils, ... }:
    with utils.lib; eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-small latex-bin latexmk moderncv colortbl fontawesome5 pgf multirow luatexbase academicons arydshln infwarerr kvoptions;
        };
      in rec {
        packages = {
          cv =  pkgs.stdenvNoCC.mkDerivation rec {
            name = "latex-demo-document";
            src = self;
            buildInputs = [ pkgs.coreutils tex ];
            nativeBuildInputs = [ pkgs.coreutils ];
            phases = ["unpackPhase" "buildPhase" "installPhase"];
            buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              latexmk -interaction=nonstopmode -pdf -lualatex \
              src/cv.tex
          '';
            installPhase = ''
            mkdir -p $out/share
            cp cv.pdf $out/share/
            '';
          };
          default = packages.cv;
        };
      });
}
