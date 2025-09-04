{
	inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

	outputs = inputs: with inputs; let
		pkgs = nixpkgs.legacyPackages.x86_64-linux;
	in with pkgs; {
		devShells.x86_64-linux.default = mkShell { nativeBuildInputs = [ odin ]; };
		packages.x86_64-linux.default = stdenv.mkDerivation {
			name = "bedrock-odin";
			src = ./.;
			buildInputs = [ odin ];
			buildPhase = "odin build .";
			installPhase = "mkdir -p $out/bin; cp *-source $out/bin/bedrock-odin";
		};
	};
}
