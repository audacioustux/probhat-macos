{
  description = "Probhat Bengali keyboard layout for macOS";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      mkProbhat = pkgs: pkgs.stdenvNoCC.mkDerivation {
        pname = "probhat-keylayout";
        version = "1.0.0";
        src = ./.;
        dontBuild = true;
        installPhase = ''
          mkdir -p "$out/Library/Keyboard Layouts"
          cp Probhat.keylayout Probhat.icns "$out/Library/Keyboard Layouts/"
        '';
        meta = {
          description = "Probhat fixed-layout Bengali keyboard for macOS";
          homepage = "https://github.com/mdminhazulhaque/probhat-macos";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.darwin;
        };
      };
    in
    {
      packages = nixpkgs.lib.genAttrs systems (system:
        let pkg = mkProbhat nixpkgs.legacyPackages.${system};
        in { probhat = pkg; default = pkg; });

      # Usage in nix-darwin:
      #   inputs.probhat-macos.url = "github:audacioustux/probhat-macos";
      #   imports = [ probhat-macos.darwinModules.default ];
      #   programs.probhat.enable = true;
      darwinModules.default = { config, lib, pkgs, ... }:
        let
          dst = "/Library/Keyboard Layouts";
          pkg = mkProbhat pkgs;
          src = "${pkg}/Library/Keyboard Layouts";
          files = [ "Probhat.keylayout" "Probhat.icns" ];
        in {
          options.programs.probhat.enable =
            lib.mkEnableOption "Probhat Bengali keyboard layout";

          config.system.activationScripts.probhat.text =
            if config.programs.probhat.enable then ''
              echo "Installing Probhat keyboard layout..." >&2
              install -m 644 "${src}/Probhat.keylayout" "${src}/Probhat.icns" "${dst}/"
            ''
            else ''
              echo "Removing Probhat keyboard layout..." >&2
              ${lib.concatMapStringsSep "\n" (f: "rm -f '${dst}/${f}'") files}
            '';
        };
    };
}